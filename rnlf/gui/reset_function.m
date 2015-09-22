function data = reset_function(data,handles)

clc

set(data.input_image_button,'String','Input image')
axes(handles.axes3)
cla reset
axis off
axes(handles.axes1)
cla reset
axis off

axes(handles.waitbar_axes)
cla reset
h=handles.waitbar_axes;
set(h,'Visible','Off');


if isfield(data,'data')
    data = data.data;
end
