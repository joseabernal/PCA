function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 30-Dec-2015 01:39:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)
    global images
    global U
    global meanImage
    global reducedD
    global names
    global gendersMap
    
    % Choose default command line output for gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);
    
    [names, images] = ReadDataset('training_images/');
    gendersMap = ReadGenders();
    
    D = zeros(length(images), size(images{1}, 1) * size(images{1}, 2));
    
    for k = 1 : length(images)
        image = images{k};
        D(k, :) = im2double(image(:))';
    end

    PCAHandler = PCA;
    k = 100; %we should iterate over this value according to sum^k(eigen)/sum^n(eigen) >= 95%
    meanImage = mean(D);
    [reducedD, U] =  PCAHandler.PerformPCA(D, k);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    global inputImage
    global U
    global meanImage

    [fileName, filePath] = uigetfile('*.pgm', 'Select the image to process');
    if (strcmp(fileName, '') == 0)
        imageToShow = im2double(imread(strcat(filePath, fileName)));
        imshow(imageToShow, 'parent', handles.axes1)
    
        inputImage = (imageToShow(:)' - meanImage) * U;
    end

% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)for i = 1 : 10
    global inputImage
    global images
    global reducedD
    global gendersMap
    global names

    reducedTestImage = inputImage;
    
    PCAHandler = PCA;
    numberOfMatches = 4;
    idx = PCAHandler.FindBestMatches(reducedTestImage, reducedD, numberOfMatches);
    
    FEMALE = 0;
    MALE = 1;
    MID_POINT = (FEMALE + MALE)/2;
    
    x = 0;
    % KNN for gender classification
    for i = 1 : numberOfMatches
        name = names{idx(i)};
        name = name(1:length(name)-6);
        x = x + gendersMap(name);
    end
    
    x = x / numberOfMatches;
    
    tag = 'MALE';
    if (x < MID_POINT)
        tag = 'FEMALE';
    end
    
    set(handles.GenderTag, 'String', tag);
    
    imshow(images{idx(1)}, 'parent', handles.axes2);
    imshow(images{idx(2)}, 'parent', handles.axes3);
    imshow(images{idx(3)}, 'parent', handles.axes4);
    imshow(images{idx(4)}, 'parent', handles.axes5);



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
