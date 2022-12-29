function varargout = segmenta_GUI(varargin)
% SEGMENTA_GUI MATLAB code for segmenta_GUI.fig
%      SEGMENTA_GUI, by itself, creates a new SEGMENTA_GUI or raises the existing
%      singleton*.
%
%      H = SEGMENTA_GUI returns the handle to a new SEGMENTA_GUI or the handle to
%      the existing singleton*.
%
%      SEGMENTA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTA_GUI.M with the given input arguments.
%
%      SEGMENTA_GUI('Property','Value',...) creates a new SEGMENTA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segmenta_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segmenta_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segmenta_GUI

% Last Modified by GUIDE v2.5 29-Dec-2022 00:28:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segmenta_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @segmenta_GUI_OutputFcn, ...
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


% --- Executes just before segmenta_GUI is made visible.
function segmenta_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segmenta_GUI (see VARARGIN)

% ********************* Parâmetros gerais editáveis:  *********************
% 
% Seleciona a PC que será lida no formato ".pcd"
handles.PcToRead= handles.staticPathReadPC.String;
% Seleciona o path onde a PC segmantada será salva:
handles.pathSavePC= handles.staticPathSavePC.String;
handles.pathReadPC= "";

%
% Parâmetros para segmentação das PCs para definir o ROI do plano, esses 
% parâmetros são usados na função pcsegdist().
handles.valMinDistance= str2double(handles.txtMinDistance.String); %0.05; 
handles.valMinPoints= str2double(handles.txtNumMinPontosPorCluster.String); %500;
handles.valMaxPoints= str2double(handles.txtNumMaxPontosPorCluster.String); %1500;

% Define os thresholds de distância e angular para segmantar a PC e definir 
% um ROI, esses parâmetros são usados na função segmentaLidarData().
handles.valThresholdMaxDistance= str2double(handles.txtThresholdMaxDistance.String);
handles.valThresholdMinDistance= str2double(handles.txtThresholdMinDistance.String);
handles.valMaxAngle= str2double(handles.txtMaxAngle.String);


%Se "handles.habFunction_SegmentaLidarData" estiver el nivel alto será habilitada
% a função "segmentaLidarData()", caso contrário serpa usada a função
% "pcsegdist".
handles.habFunction_SegmentaLidarData= handles.checkSelectFunction.Value;
handles.habSavePcSeg= 0;

handles.extPC= "pcd";
handles.showPcSegmentada= 1;


%**************************************************************************

% Choose default command line output for segmenta_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segmenta_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = segmenta_GUI_OutputFcn(hObject, eventdata, handles) 
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
[handles.file, handles.path] = uigetfile('C:\Projetos\Matlab\Experimentos\*.pcd');
handles.PcToRead= fullfile(handles.path, handles.file);
handles.pathReadPC= handles.path;
handles.staticPathReadPC.String= handles.PcToRead;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btPathSavePC.
function btPathSavePC_Callback(hObject, eventdata, handles)
% hObject    handle to btPathSavePC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pathSavePC= uigetdir('C:\Projetos\Matlab\Experimentos');
handles.staticPathSavePC.String= handles.pathSavePC;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btSair.
function btSair_Callback(hObject, eventdata, handles)
% hObject    handle to btSair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
clear;
close all;


% --- Executes on button press in btExecutar.
function btExecutar_Callback(hObject, eventdata, handles)
% hObject    handle to btExecutar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fSegmentaPC(handles);


function txtDistanciaMinima_Callback(hObject, eventdata, handles)
% hObject    handle to txtDistanciaMinima (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDistanciaMinima as text
%        str2double(get(hObject,'String')) returns contents of txtDistanciaMinima as a double


% --- Executes during object creation, after setting all properties.
function txtDistanciaMinima_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDistanciaMinima (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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



function txtNumMinPontosPorCluster_Callback(hObject, eventdata, handles)
% hObject    handle to txtNumMinPontosPorCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNumMinPontosPorCluster as text
%        str2double(get(hObject,'String')) returns contents of txtNumMinPontosPorCluster as a double
str= get(hObject, 'String');
handles.valMinPoints= str2num(str);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtNumMinPontosPorCluster_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNumMinPontosPorCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function txtMinDistance_Callback(hObject, eventdata, handles)
% hObject    handle to txtMinDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMinDistance as text
%        str2double(get(hObject,'String')) returns contents of txtMinDistance as a double
str= get(hObject, 'String');
handles.valMinDistance= str2num(str);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtMinDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMinDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Enable', 'on');


% --- Executes on button press in checkShowPCs.
function checkShowPCs_Callback(hObject, eventdata, handles)
% hObject    handle to checkShowPCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkShowPCs
value= get(hObject,'Value');
handles.showPcSegmentada= value;

% --- Executes during object creation, after setting all properties.
function checkShowPCs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkShowPCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in checkSelectFunction.
function checkSelectFunction_Callback(hObject, eventdata, handles)
% hObject    handle to checkSelectFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSelectFunction
if (hObject.Value== 1)
    handles.txtMaxAngle.Enable= 'on';
    handles.habFunction_SegmentaLidarData= 1;
else
    handles.txtMaxAngle.Enable= 'off';
    handles.habFunction_SegmentaLidarData= 0;
end


function txtThresholdMinDistance_Callback(hObject, eventdata, handles)
% hObject    handle to txtThresholdMinDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtThresholdMinDistance as text
%        str2double(get(hObject,'String')) returns contents of txtThresholdMinDistance as a double
str= get(hObject, 'String');
handles.valThresholdMinDistance= str2double(str);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtThresholdMinDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtThresholdMinDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','0.5');



function txtThresholdMaxDistance_Callback(hObject, eventdata, handles)
% hObject    handle to txtThresholdMaxDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtThresholdMaxDistance as text
%        str2double(get(hObject,'String')) returns contents of txtThresholdMaxDistance as a double
str= get(hObject, 'String');
handles.valThresholdMaxDistance= str2double(str);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtThresholdMaxDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtThresholdMaxDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','1.5');


% --- Executes on button press in checkSalvaPcSegmantada.
function checkSalvaPcSegmantada_Callback(hObject, eventdata, handles)
% hObject    handle to checkSalvaPcSegmantada (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSalvaPcSegmantada

if (hObject.Value)
    handles.btPathSavePC.Enable= 'on';
    handles.habSavePcSeg= 1;
    handles.staticPathSavePC.Enable= 'on';
else
    handles.btPathSavePC.Enable= 'off';
    handles.habSavePcSeg= 0;
    handles.staticPathSavePC.Enable= 'off';   
end
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function checkSalvaPcSegmantada_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkSalvaPcSegmantada (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value', 0);


% --- Executes during object creation, after setting all properties.
function staticPathSavePC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to staticPathSavePC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'Enable', 'off'); 


% --- Executes during object creation, after setting all properties.
function btPathSavePC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btPathSavePC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'Enable', 'off'); 



function txtNumMaxPontosPorCluster_Callback(hObject, eventdata, handles)
% hObject    handle to txtNumMaxPontosPorCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNumMaxPontosPorCluster as text
%        str2double(get(hObject,'String')) returns contents of txtNumMaxPontosPorCluster as a double
str= get(hObject, 'String');
handles.valMaxPoints= str2num(str);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtNumMaxPontosPorCluster_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNumMaxPontosPorCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtMaxAngle_Callback(hObject, eventdata, handles)
% hObject    handle to txtMaxAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMaxAngle as text
%        str2double(get(hObject,'String')) returns contents of txtMaxAngle as a double
str= get(hObject, 'String');
handles.valMaxAngle= str2double(str);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtMaxAngle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMaxAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Enable', 'off'); 


% --- Executes during object creation, after setting all properties.
function checkSelectFunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkSelectFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'Value', 0); 


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
