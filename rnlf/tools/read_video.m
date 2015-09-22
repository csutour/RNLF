function file = read_video(path_name, img_name)

obj = VideoReader([path_name img_name]);
file = double(read(obj,[1 Inf]));
file = squeeze(file(:,:,1,:));
