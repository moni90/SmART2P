function info_simulated_TS(TS,files)

if nargin == 1
    files = [];
end

info = imfinfo(TS);

global data;

data.mode = 'simulations';
data.scanningType = 'raster';
data.micronsPerPixel_XAxis = 2.5;
data.micronsPerPixel_YAxis = 2.5;
data.version_software = '';
data.reference_image = squeeze(mean(TS,3));
data.framePeriod = 1/5;
data.pixels_per_line = info(1).Width;
data.linesPerFrame = info(1).Height;
data.scanlinePeriod =  data.framePeriod/data.linesPerFrame;
data.dwellTime = 0.04;
data.frameTimes = 0:data.framePeriod:data.framePeriod*(length(info)-1);
data.duration = length(info);

data = reset_data(data);

end


