function varargout = ajustaPlano_GUI(varargin)
% AJUSTAPLANO_GUI MATLAB code for ajustaPlano_GUI.fig
%      AJUSTAPLANO_GUI, by itself, creates a new AJUSTAPLANO_GUI or raises the existing
%      singleton*.
%
%      H = AJUSTAPLANO_GUI returns the handle to a new AJUSTAPLANO_GUI or the handle to
%      the existing singleton*.
%
%      AJUSTAPLANO_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AJUSTAPLANO_GUI.M with the given input arguments.
%
%      AJUSTAPLANO_GUI('Property','Value',...) creates a new AJUSTAPLANO_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ajustaPlano_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ajustaPlano_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ajustaPlano_GUI

% Last Modified by GUIDE v2.5 05-Jan-2023 20:05:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ajustaPlano_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ajustaPlano_GUI_OutputFcn, ...
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


% --- Executes just before ajustaPlano_GUI is made visible.
function ajustaPlano_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ajustaPlano_GUI (see VARARGIN)

% Variável que guarda o endereço da nuvem de pontos a ser ajustada
handles.file= ""; % handles.staticBrowseFile.String;
handles.path= "";
handles.pathPC= "";
handles.pathOut= "analise";
handles.pathSave= "";

handles.maxDistance= str2num(handles.txtMaxDistance.String);
handles.vetorNormal= str2num(handles.txtVetorNormal.String);
handles.pontoNoPlano= str2num(handles.txtPontoNoPlano.String);
handles.numPointsSim= str2num(handles.txtNumPontosPC.String);


% Choose default command line output for ajustaPlano_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ajustaPlano_GUI wait for user response (see UIRESUME)
% uiwait(handles.panelBase);


% --- Outputs from this function are returned to the command line.
function varargout = ajustaPlano_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btPathReadPC.
function btPathReadPC_Callback(hObject, eventdata, handles)
% hObject    handle to btPathReadPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Define o path e a PC que será lida para ajustar o plano:
[handles.file, handles.path] = uigetfile(handles.staticBrowseFile.String);
handles.pathPC= fullfile(handles.path,handles.file);
handles.staticBrowseFile.String= handles.pathPC;

% Define path onde serão salvos os resultados, figuras, da análise:
handles.pathSave= sprintf('%s%s', handles.path, handles.pathOut); 
handles.staticPathSave.String= handles.pathSave; 

% Habilita o gráfico axes1 para exibir a PC:
figA= figure;
pcshow(handles.pathPC);
figA.Position= [1350, 100, 1000, 850];

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pbSair.
function pbSair_Callback(hObject, eventdata, handles)
% hObject    handle to pbSair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.panelBase.HandleVisibility= 'on';
close all;
clc;
clear;


% --- Executes on button press in pbExecAjustaPlano.
function pbExecAjustaPlano_Callback(hObject, eventdata, handles)
% hObject    handle to pbExecAjustaPlano (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Chama a função principal que efetua o ajuste de plano:
if (handles.ckHabilitaSimulacao.Value>0)
    handles.enableSimulation= 1;
    fAjustaPlanoPC(handles); 
else
    handles.enableSimulation= 0;
    if (handles.pathPC== "")
        msg=sprintf('Defina uma nuvem de pontos .pcd antes de executar!');
        msgbox(msg);
    else   
        fAjustaPlanoPC(handles);    
    end
end


function txtMaxDistance_Callback(hObject, eventdata, handles)
% hObject    handle to txtMaxDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str= get(hObject,'String');
handles.maxDistance= str2double(str);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtMaxDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMaxDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', '0.01');
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ckHabilitaSimulacao.
function ckHabilitaSimulacao_Callback(hObject, eventdata, handles)
% hObject    handle to ckHabilitaSimulacao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ckHabilitaSimulacao
if (hObject.Value== 1)
   handles.txtVetorNormal.Enable= 'on';
   handles.txtPontoNoPlano.Enable= 'on';
   handles.txtNumPontosPC.Enable= 'on';
   % handles.txtMaxDistance.Enable= 'off';
else
   handles.txtVetorNormal.Enable= 'off';
   handles.txtPontoNoPlano.Enable= 'off';
   handles.txtNumPontosPC.Enable= 'off';
  % handles.txtMaxDistance.Enable= 'on';
end

% Update handles structure
guidata(hObject, handles);


function txtVetorNormal_Callback(hObject, eventdata, handles)
% hObject    handle to txtVetorNormal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtVetorNormal as text
%        str2double(get(hObject,'String')) returns contents of txtVetorNormal as a double
str= get(hObject, 'String');
handles.vetorNormal= str2num(str);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtVetorNormal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtVetorNormal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', '0 1 0');


function txtPontoNoPlano_Callback(hObject, eventdata, handles)
% hObject    handle to txtPontoNoPlano (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPontoNoPlano as text
%        str2double(get(hObject,'String')) returns contents of txtPontoNoPlano as a double
str= get(hObject, 'String');
handles.pontoNoPlano= str2num(str);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtPontoNoPlano_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPontoNoPlano (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', '1 1 1');

function txtNumPontosPC_Callback(hObject, eventdata, handles)
% hObject    handle to txtNumPontosPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNumPontosPC as text
%        str2double(get(hObject,'String')) returns contents of txtNumPontosPC as a double
str= get(hObject, 'String');
handles.numPointsSim= str2num(str);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtNumPontosPC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNumPontosPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', '1000');


% --- Executes during object creation, after setting all properties.
function btPathReadPC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btPathReadPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function staticBrowseFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to staticBrowseFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferometro\experimento_01\out\*.pcd');


% --- Executes on button press in pbPathSave.
function pbPathSave_Callback(hObject, eventdata, handles)
% hObject    handle to pbPathSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function txtNumBins_Callback(hObject, ~, handles)
% hObject    handle to txtNumBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNumBins as text
%        str2double(get(hObject,'String')) returns contents of txtNumBins as a double
str=get(hObject, 'String');
handles.numBins= str2num(str);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtNumBins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNumBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.String= 20;
str=get(hObject, 'String');
handles.numBins= str2num(str);
% Update handles structure
guidata(hObject, handles);

