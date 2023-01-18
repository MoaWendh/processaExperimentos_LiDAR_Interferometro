function varargout = viewPointCloud_GUI(varargin)
% VIEWPOINTCLOUD_GUI MATLAB code for viewPointCloud_GUI.fig
%      VIEWPOINTCLOUD_GUI, by itself, creates a new VIEWPOINTCLOUD_GUI or raises the existing
%      singleton*.
%
%      H = VIEWPOINTCLOUD_GUI returns the handle to a new VIEWPOINTCLOUD_GUI or the handle to
%      the existing singleton*.
%
%      VIEWPOINTCLOUD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWPOINTCLOUD_GUI.M with the given input arguments.
%
%      VIEWPOINTCLOUD_GUI('Property','Value',...) creates a new VIEWPOINTCLOUD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewPointCloud_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewPointCloud_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewPointCloud_GUI

% Last Modified by GUIDE v2.5 17-Jan-2023 23:11:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewPointCloud_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @viewPointCloud_GUI_OutputFcn, ...
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


% --- Executes just before viewPointCloud_GUI is made visible.
function viewPointCloud_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewPointCloud_GUI (see VARARGIN)

% Choose default command line output for viewPointCloud_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewPointCloud_GUI wait for user response (see UIRESUME)
% uiwait(handles.figureMain);


% --- Outputs from this function are returned to the command line.
function varargout = viewPointCloud_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbVisualizar.
function pbVisualizar_Callback(hObject, eventdata, handles)
% hObject    handle to pbVisualizar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path= sprintf('%s%s', handles.pathBase,'\*.pcd');
[handles.fileSeparar, handles.path]= uigetfile(path,'MultiSelect', 'on');

% Para evitar erro, se for escolhida apenas um arquivo, nuvem de pontos,
% a variável "handles.fileSeparar" não será cell e a função length() irá determinar o
% número de caracteres contido na variável "handles.fileSeparar", isto não é
% desejável. Por isso é feito o teste abaixo:
if iscell(handles.fileSeparar)
    handles.numPCs= length(handles.fileSeparar);
else
    handles.numPCs= 1;
end

for (ctPC=1:handles.numPCs)
    close all;
    % Gera o path para ler a PC:
    if (handles.numPCs==1)
        nameFile= handles.fileSeparar;
    else
        nameFile= handles.fileSeparar{ctPC};
    end
    handles.PcToRead= fullfile(handles.path, nameFile);
    
    % Ler a respectiva nuvem de pontos:
    pc= pcread(handles.PcToRead);
    % Exibe a nuvem depontos:
    pcshow(pc);
    msg= sprintf('Nuvem de pontos nº %d',ctPC);
    title(msg);
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
    
    msg= sprintf('Nuvem de pontos nº %d - Arq. %s', ctPC, nameFile);
    answer= questdlg(msg, 'Show PC', 'Ok', 'Ok');
    pathFullReadPC= fullfile(handles.PcToRead);  
end

msg= sprintf(' Finalizado!!\n Foram exibidas %d PCs.',ctPC);
answer= questdlg(msg, 'Programa Show PC', 'Ok', 'Ok');
pathFullReadPC= fullfile(handles.PcToRead);  

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in pbSair.
function pbSair_Callback(hObject, eventdata, handles)
% hObject    handle to pbSair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.figureMain.HandleVisibility= 'on';

close all;
clear;
clc;


% --- Executes during object creation, after setting all properties.
function pbVisualizar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbVisualizar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.pathBase= 'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferometro\experimento_01\out\pcReg';

% Update handles structure
guidata(hObject, handles);
