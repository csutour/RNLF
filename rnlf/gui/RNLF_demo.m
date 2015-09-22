function varargout = RNLF_demo(varargin)
% RNLF_DEMO MATLAB code for RNLF_demo.fig
%      RNLF_DEMO, by itself, creates a new RNLF_DEMO or raises the existing
%      singleton*.
%
%      H = RNLF_DEMO returns the handle to a new RNLF_DEMO or the handle to
%      the existing singleton*.
%
%      RNLF_DEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RNLF_DEMO.M with the given input arguments.
%
%      RNLF_DEMO('Property','Value',...) creates a new RNLF_DEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RNLF_demo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RNLF_demo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RNLF_demo

% Last Modified by GUIDE v2.5 21-Apr-2015 15:38:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RNLF_demo_OpeningFcn, ...
    'gui_OutputFcn',  @RNLF_demo_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before RNLF_demo is made visible.
function RNLF_demo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RNLF_demo (see VARARGIN)

% Choose default command line output for RNLF_demo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes RNLF_demo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RNLF_demo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%

% --- reset_button
% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(gcbf);
data=reset_function(data,handles);
guidata(gcbf,data);



% --- See data
% --- Executes on button press in see_data_button.
function see_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to see_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(gcbf);
disp(data)




% --- Input data
% --- Executes on button press in input_image_button.
function input_image_button_Callback(hObject, eventdata, handles)
% hObject    handle to input_image_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data = guidata(gcbf);

data = reset_function(data,handles); %reset data
if ~isfield(data,'data')
    data.data=data;
end

[img_name,path_name] = uigetfile('*','Select the input image :');
if ~img_name
    return
end
[~, ~, ext] = fileparts([path_name img_name]);
switch ext
    case '.mat'
        data.img = importdata([path_name img_name]);
    case '.avi'
        data.img = read_video(path_name, img_name);
    otherwise
        data.img = double(imread([path_name img_name]));
end

axes(handles.axes3)
cla reset
axis off

h=handles.waitbar_axes;
set(h,'Visible','Off');


axes(handles.axes1)
hold off
imagesc(data.img(:,:,1),[0 255]),colormap('gray'),axis image,axis off
title('Data')

set(hObject,'String',['Input image : ' path_name img_name])

guidata(gcbf,data);



% --- Noise generation
% --- Executes on button press in noise_generation_button.
function data = noise_generation_button_Callback(hObject, eventdata, handles)
% hObject    handle to noise_generation_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data = guidata(gcbf);

if isfield(data,'NLF')
    data=rmfield(data,'NLF');
end
if isfield(data,'res')
    data=rmfield(data,'res');
end
if isfield(data,'stat')
    data=rmfield(data,'stat');
end
if isfield(data,'sig_gen')
    data=rmfield(data,'sig_gen');
end


noise_model=input('Select the noise model you wish to generate: \n 0- Hybrid \n 1- Gaussian\n 2- Poisson\n 3- Gamma\n [Default: 0]\n');
if isempty(noise_model)
    noise_model = 0;
end
switch noise_model
    case 1
        data.noisegen = 'gauss';
    case 2
        data.noisegen = 'poisson';
    case 3
        data.noisegen = 'gamma';
    otherwise
        data.noisegen = 'hybrid';
end

switch data.noisegen
    case 'hybrid'
        sigma = 40; % if Gaussian
        Q = 10; % if Poisson
        L = 2; % if gamma
        coef = [1/4 1/4 1/2]; % if hybrid --> proportion of gamma, Poisson and Gaussian noise
        sigma_input=input('Select the Gaussian component [Default: 40]\n');
        if isempty(sigma_input)
            sigma_input = sigma;
        end
        Q_input=input('Select the Poisson component [Default: 10]\n');
        if isempty(Q_input)
            Q_input = Q;
        end
        L_input=input('Select the multiplicative component [Default: 2]\n');
        if isempty(L_input)
            L_input = L;
        end
        data.sig_gen = cat(2,coef',[L_input;Q_input;sigma_input]);
        A=[coef(1)^2/L_input coef(2)^2*Q_input coef(3)^2*sigma_input^2];
        disp(['Parameters for hybrid noise: [a b c] = ' num2str(A)])
    case 'gauss'
        data.sig_gen=input('Select the noise parameter: \sigma = [Default: 40]\n');
        if isempty(data.sig_gen)
            data.sig_gen = 40;
        end
    case 'poisson'
        data.sig_gen=input('Select the noise parameter: Q = [Default: 10]\n');
        if isempty(data.sig_gen)
            data.sig_gen = 10;
        end
    case 'gamma'
        data.sig_gen=input('Select the noise parameter: L = [Default: 4]\n');
        if isempty(data.sig_gen)
            data.sig_gen = 4;
        end
end

% To analyze
data.noise = data.noisegen;

img = data.img;
img_nse = noisegen(img,data.noisegen,data.sig_gen);
data.img_nse = img_nse;

data.psnr_init = mean(10*log10((255^2)/(sum(sum(( (data.img-data.img_nse).^2),2),1)/(size(data.img,1)*size(data.img,2)))));

axes(handles.axes1)
hold off
imagesc(img_nse(:,:,1),[0 255]),colormap('gray'),axis image,axis off
title(['Noisy data, initial PSNR = ' num2str(data.psnr_init)])

guidata(gcbf,data);



% --- Homogeneous detection
% --- Executes on button press in homogeneous_detection_button.
function homogeneous_detection_button_Callback(hObject, eventdata, handles)
% hObject    handle to homogeneous_detection_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(gcbf);

if ~isfield(data,'img_nse')
    data.img_nse = data.img;
end

if isfield(data,'NLF')
    data=rmfield(data,'NLF');
end
if isfield(data,'res')
    data=rmfield(data,'res');
end

disp('Homogeneous detection...')
data.W=16;
data = homogeneous_detection(data,handles);

guidata(gcbf,data);






% --- Noise estimation
% --- Executes on button press in noise_estimation_button.
function noise_estimation_button_Callback(hObject, eventdata, handles)
% hObject    handle to noise_estimation_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(gcbf);

if isfield(data,'NLF')
    data=rmfield(data,'NLF');
end
if isfield(data,'res')
    data=rmfield(data,'res');
end


data = noise_estimation(data,handles);

guidata(gcbf,data);


% --- R-NLF denoising
% --- Executes on button press in RNLF_button.
function RNLF_button_Callback(hObject, eventdata, handles)
% hObject    handle to RNLF_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(gcbf);

if ~isfield(data,'img_nse') && ~isfield(data,'NLF') && ~isfield(data,'stat')
    answer = input('Do you wish to add noise to the input image ? Y/N [Default : N]','s');
    if isempty(answer)
        answer='N';
    end
    switch answer
        case {'Y','y'}
            data = noise_generation_button_Callback(hObject, eventdata, handles);
        case {'N','n'}
            data.img_nse = data.img;
    end
end


data = RNLFgui(data,handles);

guidata(gcbf,data);


% --- Executes on button press in read_me_button.
function read_me_button_Callback(hObject, eventdata, handles)
% hObject    handle to read_me_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

type READ_me.txt


% --- Executes on button press in save_data_button.
function save_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = guidata(gcbf);
[FileName,PathName] = uiputfile('data.mat','Select path and name to save the data');
save([PathName FileName],'data')
