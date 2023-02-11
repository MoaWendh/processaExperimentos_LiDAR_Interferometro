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

% Last Modified by GUIDE v2.5 11-Feb-2023 17:12:02

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
handles.PcToRead= 'C:\Projetos\Matlab';

% Seleciona o path onde a PC segmantada será salva:
handles.pathBase= 'C:\Projetos\Matlab\Experimentos';
handles.pathSavePC= "";
handles.pathReadPC= handles.pathBase;
handles.nameFolderSavePcSeg= 'segmentada'; 

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


%Se "handles.habFunction_SegmentaLidarData" estiver el nivel alto será habilitada
% a função "segmentaLidarData()", caso contrário serpa usada a função
% "pcsegdist".

handles.extPC= "pcd";


% Rotina para fechar todas as figuras aberrtas no Matalab:
%n= length(figure);
%for (i=1:n)
 %   close(figure i);
%end


%**************************************************************************

% Choose default command line output for segmenta_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segmenta_GUI wait for user response (see UIRESUME)
% uiwait(handles.panelMain);


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
path= fullfile(handles.pathBase,'*.pcd');
[handles.file, handles.path] = uigetfile(path);
handles.PcToRead= fullfile(handles.path, handles.file);
handles.pathReadPC= handles.path;

if handles.file
    handles.pathBase= handles.path;
    handles.btSegmentar.Enable= 'on';
else
    msg= sprintf(' Path de leitura da PC indefinido. \n Para liberar a segmentação defina o path.');
    figMsg= msgbox(msg);
    uiwait(figMsg);
    
    handles.btSegmentar.Enable= 'off';
end

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in btSair.
function btSair_Callback(hObject, eventdata, handles)
% hObject    handle to btSair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.panelMain.HandleVisibility= 'on';
close all;
clc;
clear;


% --- Executes on button press in btSegmentar.
function btSegmentar_Callback(hObject, eventdata, handles)
% hObject    handle to btSegmentar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles= fSegmentaPC(handles);


% Update handles structure
guidata(hObject, handles);



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
set(hObject, 'Enable', 'off');


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
set(hObject, 'Enable', 'off');


% --- Executes on button press in checkShowPCs.
function checkShowPCs_Callback(hObject, eventdata, handles)
% hObject    handle to checkShowPCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkShowPCs
handles.showPcSegmentada= get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function checkShowPCs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkShowPCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.showPcSegmentada= get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkSelectSegByThreshold.
function checkSelectSegByThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to checkSelectSegByThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSelectSegByThreshold
if (hObject.Value)
    % Habilita o uso da função de segmentação do Matlab pcsegdist():
    handles.txtMinDistance.Enable= 'on';
    handles.txtNumMinPontosPorCluster.Enable= 'on';
    handles.txtNumMaxPontosPorCluster.Enable= 'on';
    handles.txtThresholdMinDistance.Enable= 'off';
    handles.txtThresholdMaxDistance.Enable= 'off';
    handles.habSegmentaPorThreshold= 0;
else
    % Habilita o uso da função de segmentação usando o threshold de
    % distancia m[inima e máxima:
    handles.txtMinDistance.Enable= 'off';
    handles.txtNumMinPontosPorCluster.Enable= 'off';
    handles.txtNumMaxPontosPorCluster.Enable= 'off';
    handles.txtThresholdMinDistance.Enable= 'on';
    handles.txtThresholdMaxDistance.Enable= 'on';
    handles.habSegmentaPorThreshold= 1; 
end

% Update handles structure
guidata(hObject, handles);

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
set(hObject,'String','1.2');


% --- Executes on button press in checkSalvaPcSegmantada.
function checkSalvaPcSegmantada_Callback(hObject, eventdata, handles)
% hObject    handle to checkSalvaPcSegmantada (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkSalvaPcSegmantada

handles.HabSalvarPcSeg= hObject.Value;

% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function checkSalvaPcSegmantada_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkSalvaPcSegmantada (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.HabSalvarPcSeg= 0;

% Update handles structure
guidata(hObject, handles);


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
set(hObject, 'Enable', 'off');


% --- Executes during object creation, after setting all properties.
function checkSelectSegByThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkSelectSegByThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'Value', 0); 
% Inicia habilitando o uso da função de segmentação por threshold de
% distância mínima e máxima:
handles.habSegmentaPorThreshold= 1;
% Update handles structure
guidata(hObject, handles);

% --- Executes when panelMain is resized.
function panelMain_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to panelMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function btPathReadPC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btPathReadPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Abre janela para escolher as PC a serem rotacionadas:
path= fullfile(handles.pathBase,'*.pcd');
[files pathBase]= uigetfile(path,'Selecione uma PC para Visualização.');
fullPathPC= fullfile(pathBase, files);

if files
    handles.pathBase= pathBase;
    % Faz a leitura da PC:
    pc= pcread(fullPathPC);

    % Exine a PC lida:
    figure; 
    pcshow(pc.Location);

    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end

% Update handles structure
guidata(hObject, handles);

