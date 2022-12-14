function varargout = testaAlgoritmosRegistro_GUI(varargin)
%TESTAALGORITMOSREGISTRO_GUI MATLAB code file for testaAlgoritmosRegistro_GUI.fig
%      TESTAALGORITMOSREGISTRO_GUI, by itself, creates a new TESTAALGORITMOSREGISTRO_GUI or raises the existing
%      singleton*.
%
%      H = TESTAALGORITMOSREGISTRO_GUI returns the handle to a new TESTAALGORITMOSREGISTRO_GUI or the handle to
%      the existing singleton*.
%
%      TESTAALGORITMOSREGISTRO_GUI('Property','Value',...) creates a new TESTAALGORITMOSREGISTRO_GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to testaAlgoritmosRegistro_GUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      TESTAALGORITMOSREGISTRO_GUI('CALLBACK') and TESTAALGORITMOSREGISTRO_GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in TESTAALGORITMOSREGISTRO_GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testaAlgoritmosRegistro_GUI

% Last Modified by GUIDE v2.5 26-Dec-2022 10:28:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testaAlgoritmosRegistro_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @testaAlgoritmosRegistro_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before testaAlgoritmosRegistro_GUI is made visible.
function testaAlgoritmosRegistro_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Defini????o de alguns paths:
% Os ??nicos paths que precisam serem definidos s??o o handles.path.BaseRead e
% o handles.path.BaseSave:

handles.path.BaseRead= handles.staticPathRead.String;
handles.path.BaseSave= handles.staticPathSave.String;

% Outros paths fixos, que s??o gerados automaticametne pelo programa:
handles.path.PCReg= '\out\pcReg'; % Folder onde ser??o salvas as PCs registradas
handles.path.PCCanais= '\out\pcRegPorCanal\cn'; % Folder onde ser??o salvas as PCS segmentadas com o ROI referente ao plano.
handles.path.PCFull= '\out\pcRegConcatenada'; % Folder onde ser??o salvas as PCs full, ou seja, concatenadas ap??s o resgistro.
handles.path.tform= '\out\tform'; % Folder onde ser??o salvas as PCs full, ou seja, concatenadas ap??s o resgistro.

% Captura o n??mero de folders contendo as PCs corresponde ao n?? de dist??ncias
% medidas:
handles.val.numFolders= str2double(handles.txtDistanciasMedidas.String); 

% Defini????o de alguns nomes de arquivos:
handles.name.FolderBase= '\2022_11_25_01_';
handles.name.FileBase  = '\2022_11_25_01_';
handles.name.FileTForm = 'tform';
handles.name.FileDataInterferometro = '\interferometro_exp_01.mat';

% defini????o da extens??o de alguns arquivos:
handles.name.extPC= 'pcd';

% Parametros que definem quantas PCs ser??o lidas por folder:
handles.val.fileIni= 3;
handles.val.fileEnd= 3;

% Par??metros com flags para habilitar a exibi????o de dados:
handles.show.PC= 0;
handles.show.PCReg= 0;
handles.show.Data= 1;

% Flags que habilitam algumas fun????es: 
handles.hab.TesteRegistro= 1; % Habilita a varia????o dos par??metros para teste de registro.
handles.hab.VariacaoMetricaRegistro= 0;

% Parametros para defini????o do algoritmo usado para o registro das PCS
handles.algorithm.Reg= 'ICP';

% Parametros para defini????o do algoritmo usado para subamostrar as PCS
handles.algorithm.SubSample= 'gridAverage';

% Parametro usado para fazer o merge das PCs
handles.val.mergeSize= 0.001;

% Par??metros para avalia????o dos algoritmos de registro:
handles.val.VariacaoGridSize= 10;
handles.val.VariacaoMetrica= 2;

% Par??metros para efetuar o downSample da PC. No Matalab tem 3 m??todos:
% 1) "pcdownsample(ptCloudIn,'random',percentage)", onde a escolha dos pontos
% segue um creit??rio aleat??rio. Usada apenas para pointo-a-ponto.
% 2) "pcdownsample(ptCloudIn,'gridAverage',gridStep)", faz uma subamostragem
% baseada num filtro especificado pelo grid de um 3D box, ou volume c??bico.
% Esta ?? usada tanto para ponto-a-ponto quanto ponto-a-plano.  
% 3) "pcdownsample(ptCloudIn,'nonuniformGridSample',maxNumPoints)", a
% filtragem ?? baseada num volume cubico tamb??m, por??m o grid n??o ?? definido, 
% apenas a quantiade de pontos contida no volume.
% Tamb??m define a m??trica do registro em fun????o do algoritmo de
% subamostragem, se ?? ponto-a-ponto ou ponto-a-plano.

handles.val.percentage= str2double(handles.txtPercentualReducaoDS.String); %0.2;  % Usado no m??todo 1- Percentual de redu????o da PC entre 0 e 1; 
handles.val.gridSize= str2double(handles.txtGridSize.String); % Usado no m??todo 2- Define o grid do volume c??bico, 3D Box, em metros.
handles.val.maxNumPoints= str2double(handles.txtMaxNumPoints.String); %6;  % Usado no m??todo 3- max. quantidadde de pontos para 3D Box, o m??nimo ?? 6.

handles.enable.SetPercentual= 'off';

% Choose default command line output for testaAlgoritmosRegistro_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes testaAlgoritmosRegistro_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testaAlgoritmosRegistro_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupAlgoritmoReg.
function popupAlgoritmoReg_Callback(hObject, eventdata, handles)
% hObject    handle to popupAlgoritmoReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupAlgoritmoReg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupAlgoritmoReg
str= get(hObject, 'String');
val= get(hObject, 'Value'); 
handles.algorithm.Reg= str{val};
fprintf('Algoritmo de registro usado= %s\n', handles.algorithm.Reg);
% Update handles structure
guidata(hObject, handles);     
        
% --- Executes during object creation, after setting all properties.
function popupAlgoritmoReg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupAlgoritmoReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btExecutar.
function btExecutar_Callback(hObject, eventdata, handles)
% hObject    handle to btExecutar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
fprintf('Iniciando teste de desempenho do regostor das PCs do LiDAR...\n');
% Chama callback para realizar o testa de desempenho de registro: 
fTestaRegistro(handles);


% --- Executes on selection change in popupAlgoritmoSubAmostra.
function popupAlgoritmoSubAmostra_Callback(hObject, eventdata, handles)
% hObject    handle to popupAlgoritmoSubAmostra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupAlgoritmoSubAmostra contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupAlgoritmoSubAmostra
str= get(hObject, 'String');
val= get(hObject, 'Value'); 
handles.algorithm.SubSample= str{val};
fprintf('Algoritmo de sub amostragem usado= %s\n', handles.algorithm.SubSample);

% Seleciona os par??metros dos algoritmos de registro e de sub-amostragem em
% fun????o da t??cnica utilizada pelo algoritmo de subamostragem:
switch (handles.algorithm.SubSample)
    case 'Random'
        handles.val.registerMetric='pointToPoint'; 
        handles.val.DownSampleIni= handles.val.percentage;
        handles.txtPercentualReducaoDS.Enable= 'on';
        handles.txtMaxNumPoints.Enable= 'off';
        handles.txtGridSize.Enable= 'off';
    case 'gridAverage'
        handles.val.registerMetric='pointToPlane';
        handles.val.DownSampleIni= handles.val.gridSize;
        handles.txtPercentualReducaoDS.Enable= 'off';
        handles.txtMaxNumPoints.Enable= 'off';
        handles.txtGridSize.Enable= 'on';
    case 'nonUniformGrid'
        handles.val.registerMetric='pointToPlane';
        handles.val.DownSampleIni= handles.val.maxNumPoints;
        handles.txtPercentualReducaoDS.Enable= 'off';
        handles.txtMaxNumPoints.Enable= 'on';
        handles.txtGridSize.Enable= 'off';
    otherwise 
        warning('Unexpected plot type. No plot created.');
end

% Update handles structure
guidata(hObject, handles);  

% --- Executes during object creation, after setting all properties.
function popupAlgoritmoSubAmostra_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupAlgoritmoSubAmostra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Value',2);
handles.val.DownSampleIni= handles.val.gridSize;
handles.txtPercentualReducaoDS.Enable= 'off';
handles.txtMaxNumPoints.Enable= 'off';
handles.txtGridSize.Enable= 'on';
handles.val.registerMetric='pointToPlane';

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btPathBaseRead.
function btPathBaseRead_Callback(hObject, eventdata, handles)
% hObject    handle to btPathBaseRead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.path.BaseRead= uigetdir(handles.staticPathRead.String);
% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Registro_Callback(hObject, eventdata, handles)
% hObject    handle to Registro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SubAmostragem_Callback(hObject, eventdata, handles)
% hObject    handle to SubAmostragem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function panelMain_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to panelMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function uipanel5_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uipanel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function txtPercentualReducaoDS_Callback(hObject, eventdata, handles)
% hObject    handle to txtPercentualReducaoDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPercentualReducaoDS as text
%        str2double(get(hObject,'String')) returns contents of txtPercentualReducaoDS as a double
str= get(hObject, 'String');
val= str2double(str);
if (val>=0 && val<=1)
    handles.val.percentage= str2double(str);
    handles.val.DownSampleIni= handles.val.percentage;
    fprintf('Valor do percentual de redu????o setado para -> %d\n', handles.val.percentage);
    % Update handles structure
    guidata(hObject, handles);    
else
    fprintf('Entre com um valor v??lido entre 0 e 1.\n');    
end


% --- Executes during object creation, after setting all properties.
function txtPercentualReducaoDS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPercentualReducaoDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Enable' , 'off');
str= get(hObject,'String');
handles.val.percentage= str2double(str);
% Update handles structure
guidata(hObject, handles);  

function txtGridSize_Callback(hObject, eventdata, handles)
% hObject    handle to txtGridSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtGridSize as text
%        str2double(get(hObject,'String')) returns contents of txtGridSize as a double
str= get(hObject, 'String');
val= str2double(str);
if (val>0)
    handles.val.gridSize= str2double(str);
    handles.val.DownSampleIni= handles.val.gridSize; 
    fprintf('Valor do gridSize setado para -> %d\n', handles.val.gridSize);
    % Update handles structure
    guidata(hObject, handles);    
else
    fprintf('Entre com um valor v??lido maior que zero (>0).\n');    
end

% --- Executes during object creation, after setting all properties.
function txtGridSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtGridSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
str= get(hObject, 'String');
handles.val.gridSize= str2double(str);
% Update handles structure
guidata(hObject, handles);    

function txtMaxNumPoints_Callback(hObject, eventdata, handles)
% hObject    handle to txtMaxNumPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMaxNumPoints as text
%        str2double(get(hObject,'String')) returns contents of txtMaxNumPoints as a double
str= get(hObject, 'String');
val= str2double(str);
if (val>0)
    handles.val.maxNumPoints= str2double(str);
    handles.val.gridSize= handles.val.maxNumPoints;
    fprintf('Valor do maxNumPoints foi setado para -> %d\n', handles.val.maxNumPoints);
    % Update handles structure
    guidata(hObject, handles);    
else
    fprintf('Entre com um valor v??lido maior que zero (>0).\n');    
end

% --- Executes during object creation, after setting all properties.
function txtMaxNumPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMaxNumPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Enable' , 'off');
str= get(hObject,'String');
handles.val.maxNumPoints= str2double(str);
% Update handles structure
guidata(hObject, handles);  


% --- Executes on button press in btPathBaseSave.
function btPathBaseSave_Callback(hObject, eventdata, handles)
% hObject    handle to btPathBaseSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.path.BaseSave= uigetdir(handles.staticPathSave.String);
% Update handles structure
guidata(hObject, handles);


function txtNumIteracoes_Callback(hObject, eventdata, handles)
% hObject    handle to txtNumIteracoes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNumIteracoes as text
%        str2double(get(hObject,'String')) returns contents of txtNumIteracoes as a double
str= get(hObject,'String');
handles.val.VariacaoGridSize= str2num(str);
fprintf('Definido %d', handles.val.VariacaoGridSize);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function txtNumIteracoes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNumIteracoes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
str= get(hObject,'String');
handles.val.VariacaoGridSize= str2num(str);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btSair.
function btSair_Callback(hObject, eventdata, handles)
% hObject    handle to btSair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear;
clc;
close all;


function txtDistanciasMedidas_Callback(hObject, eventdata, handles)
% hObject    handle to txtDistanciasMedidas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDistanciasMedidas as text
%        str2double(get(hObject,'String')) returns contents of txtDistanciasMedidas as a double
str= get(hObject,'String');
handles.val.numFolders= str2double(str);
fprintf('Redefinido o n?? de dist??ncias medidas para: %d', handles.val.numFolders);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtDistanciasMedidas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDistanciasMedidas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function staticPathRead_CreateFcn(hObject, eventdata, handles)
% hObject    handle to staticPathRead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferometro\experimento_01\pcd');



% --- Executes during object creation, after setting all properties.
function staticPathSave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to staticPathSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferometro\experimento_01');


% --- Executes during object creation, after setting all properties.
function btPathBaseRead_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btPathBaseRead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function btPathBaseSave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btPathBaseSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function btSair_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btPathBaseSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
