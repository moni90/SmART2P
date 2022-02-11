function [header, data, success_import] = readLineScanDataFiles(data, fileName, frame_num)

if nargin<3
    frame_num = NaN;
end
linePerFrame = 100; %arbitrary
    
%     curr_dir = pwd;
%     cd(data.path);
    meta = strfind(fileName, '.meta.txt');
    dat = strfind(fileName, '.pmt.dat');
    
    if ~isempty(meta)
        fileNameStem = fileName(1:meta-1);
        metaFileName = [fileNameStem '.meta.txt'];
    elseif ~isempty(dat)
        fileNameStem = fileName(1:dat-1);
        metaFileName = [fileNameStem '.meta.txt'];
    else
        % Both are epty, file name stem? 
        fileNameStem = fileName;
        metaFileName = [fileNameStem '.meta.txt'];
    end
    
    % read metadata
    fid = fopen(fullfile(data.path,metaFileName),'rt');
    assert(fid > 0, 'Failed to open metadata file.');
    headerStr = fread(fid,'*char')';
    fclose(fid);
    
    % parse metadata
    if headerStr(1) == '{'
        data = loadjson(headerStr);
        header = data{1};
        rgData = data{2};
    else
        rows = textscan(headerStr,'%s','Delimiter','\n');
        rows = rows{1};
        
        rgDataStartLine = find(cellfun(@(x)strncmp(x,'{',1),rows),1);
        header = decodeHeaderLines(rows(1:rgDataStartLine-1));
        
        rgStr = strcat(rows{rgDataStartLine:end});
        rgData = loadjson(rgStr);
    end
%     roiGroup = scanimage.mroi.RoiGroup.loadobj(rgData.RoiGroups.imagingRoiGroup);
    
    % read and parse pmt data
    header.acqChannels = header.SI.hChannels.channelSave;
    nChannels = numel(header.acqChannels);
    fid = fopen(fullfile(data.path,[fileNameStem '.pmt.dat']));
    assert(fid > 0, 'Failed to open pmt data file.');
    pmtData = fread(fid,inf,'int16');
    fclose(fid);
    
    % add useful info to header struct
    header.sampleRate = header.SI.hScan2D.sampleRate;
    header.numSamples = size(pmtData,1)/nChannels;
    header.acqDuration = header.numSamples / header.sampleRate;
    header.samplesPerFrame = header.SI.hScan2D.lineScanSamplesPerFrame;
    header.frameDuration = header.samplesPerFrame / header.sampleRate;
    header.numFrames = ceil(header.numSamples / header.samplesPerFrame);
%     N = header.samplesPerFrame * header.numFrames * nChannels;
%     pmtData(end+1:N,:) = nan;
%     pmtData = permute(reshape(pmtData,nChannels,header.samplesPerFrame,[]),[2 1 3]);
    
    %%% change with respect to original ScanImage code
    FOV_corners = header.SI.hScan2D.fovCornerPoints;
    FOV_width = FOV_corners(2,1)-FOV_corners(1,1);
    FOV_height = FOV_corners(3,2)-FOV_corners(2,2);
    data.reference_image = zeros(ceil(FOV_height), ceil(FOV_width));
    
    data.scanlinePeriod = header.frameDuration;
    data.framePeriod = data.scanlinePeriod;
    data.linesPerFrame = header.numFrames;
    data.duration = header.numFrames;
    data.frameTimes = 1:header.numFrames;%*data.linesPerFrame;
    data.frameTimes = data.frameTimes*data.framePeriod-data.framePeriod;

    data.micronsPerPixel_XAxis = 1;
    data.micronsPerPixel_YAxis = 1; 
    data.dwellTime = header.SI.hScan2D.scanPixelTimeMean;
    
    data.linesPerFrame = 1;
    data.pixels_per_line =  header.samplesPerFrame;

    data = reset_data(data);
    data.linesPerFrame = 1;
    
    N = data.duration*nChannels*data.pixels_per_line;
    pmtData(end+1:N,:) = nan;
    pmtData = permute(reshape(pmtData,nChannels,data.pixels_per_line,[]),[3 2 1]);
    if isnan(frame_num)
        movie = squeeze(pmtData);
    else
        keep_frames = nanmin(frame_num*linePerFrame,data.duration);
        movie = squeeze(pmtData(1:keep_frames,1,:));
    end
    clear pmtData;
    
    if size(movie,1)~=data.duration
        data.duration = size(movie,1);
        data.activities = zeros(1,data.duration);
        data.activities_original = zeros(1,data.duration);
        data.pixelsTimes = zeros(1,data.duration);
        data.bg_activity =  zeros(1,data.duration);
        data.activities_deconvolved = zeros(1,data.duration);
        data.frameTimes = data.frameTimes(1:data.duration);
    end
    
    %save the movie
    data.movie_doc.movie_ruido = movie;
    data.movie_doc.num_frames = data.duration;
    clear movie;
    %%%
    
    % read and parse scanner position data
    fid = fopen(fullfile(data.path,[fileNameStem '.scnnr.dat']));
    if fid > 0
        dat = fread(fid,inf,'single');
        fclose(fid);
        
        nScnnrs = header.SI.hScan2D.lineScanNumFdbkChannels;
        header.feedbackSamplesPerFrame = header.SI.hScan2D.lineScanFdbkSamplesPerFrame;
        header.feedbackSampleRate = header.SI.hScan2D.sampleRateFdbk;
        header.numFeedbackSamples = size(dat,1)/nScnnrs;
        if ~isempty(header.feedbackSamplesPerFrame)
            header.numFeedbackFrames = ceil(header.numFeedbackSamples / header.feedbackSamplesPerFrame);
        else
            header.feedbackSamplesPerFrame = ceil(header.numFeedbackSamples/header.numFrames);
            header.numFeedbackFrames = header.numFrames;
        end
        % pad data if last frame was partial
        N = header.feedbackSamplesPerFrame * header.numFeedbackFrames * nScnnrs;
        dat(end+1:N,:) = nan;
        
        dat = permute(reshape(dat,nScnnrs,header.feedbackSamplesPerFrame,[]),[2 1 3]);
        scannerPosData.G = dat(:,1:2,:);
        if nScnnrs > 2
            scannerPosData.Z = dat(:,3,:);
        end
    else
        scannerPosData = [];
    end
    
    %%%%%%%
    if ~isempty(scannerPosData)
    data.mode = 'freehand';
    data.scanningType = 'ScanImage';
    scan_path_0 = nanmean(scannerPosData.G(:,:,2:end),3)';
    t0 = [0:1:(header.feedbackSamplesPerFrame-1)]/header.feedbackSampleRate;
    tEnd = linspace(0,t0(end),header.samplesPerFrame);%0:1/header.sampleRate:t0(end);
    scan_path = zeros(2,header.samplesPerFrame);
    scan_path(1,:) = interp1(t0,scan_path_0(1,:),tEnd) - FOV_corners(1,1);
    scan_path(2,:) = interp1(t0,scan_path_0(2,:),tEnd) - FOV_corners(1,2);
    distancias = (sqrt(diff(scan_path(1,:)).^2 + diff(scan_path(2,:)).^2));
    distancia = sum(distancias);
    data.freehand_scan = scan_path(2:-1:1,:);
    success_import = 1;
    figure; imagesc(data.reference_image);
    figure; scatter(scan_path(1,:),scan_path(2,:),'r.');
    else
        success_import = 0;
        errordlg('No linescan trajectory available.')
    end
    %%%%%
%     cd(curr_dir);
end

%--------------------------------------------------------------------------%
% readLineScanDataFiles.m                                                  %
% Copyright � 2020 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage is licensed under the Apache License, Version 2.0              %
% (the "License"); you may not use any files contained within the          %
% ScanImage release  except in compliance with the License.                %
% You may obtain a copy of the License at                                  %
% http://www.apache.org/licenses/LICENSE-2.0                               %
%                                                                          %
% Unless required by applicable law or agreed to in writing, software      %
% distributed under the License is distributed on an "AS IS" BASIS,        %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. %
% See the License for the specific language governing permissions and      %
% limitations under the License.                                           %
%--------------------------------------------------------------------------%
