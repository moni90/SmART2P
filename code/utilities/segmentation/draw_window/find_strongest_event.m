function event = find_strongest_event(selected_pixels)
global data
video = data.movie_doc.movie_ruido;
global_activity = sum(video(:,selected_pixels),2);
[~,event] = max(global_activity);
