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

% Last Modified by GUIDE v2.5 22-Dec-2022 15:40:30

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
handles.pcFile= "";
handles.pcPath= "";
handles.pathFull= "";

handles.maxDistance= str2num(handles.txtMaxDistance.String);
handles.vetorNormal= str2num(handles.txtVetorNormal.String);
handles.pontoNoPlano= str2num(handles.txtPontoNoPlano.String);
handles.numPointsSim= str2num(handles.txtNumPontosPC.String);


% Choose default command line output for ajustaPlano_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ajustaPlano_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ajustaPlano_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btPathPC.
function btPathPC_Callback(hObject, eventdata, handles)
% hObject    handle to btPathPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Faz a leitura da nuvem de pontos para ajuste de plano:
[handles.pcFile, handles.pcPath] = uigetfile('D:\Moacir\ensaios\*.pcd',...
                                             'Selecione a nuvem de pontos');
handles.pathFull= fullfile(handles.pcPath,handles.pcFile);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pbSair.
function pbSair_Callback(hObject, eventdata, handles)
% hObject    handle to pbSair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear;
clc;
close all;


% --- Executes on button press in pbExecuta.
function pbExecuta_Callback(hObject, eventdata, handles)
% hObject    handle to pbExecuta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Chama a função principal que efetua o ajuste de plano:
if (handles.ckHabilitaSimulacao.Value>0)
    handles.enableSimulation= 1;
    fAjustaPlanoPC(handles); 
else
    handles.enableSimulation= 0;
    if (handles.pcFile== "")
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