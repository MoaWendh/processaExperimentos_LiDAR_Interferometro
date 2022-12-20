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

% Last Modified by GUIDE v2.5 20-Dec-2022 19:31:05

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

% Definição de alguns paths:
% O único path que precisa ser definido é o handles.path.Base, os outros são
handles.path.Base= 'D:\Moacir\ensaios\2022.11.25 - LiDAR Com Interferometro\experimento_01';
% Outros paths fixos:
handles.path.PC= '\original';
handles.path.PCReg= '\Reg'; % Folder onde serão salvas as PCs registradas
handles.path.PCSeg= '\Seg'; % Folder onde serão salvas as PCS segmentadas com o ROI referente ao plano.
handles.path.PCPlaneAdjuste= '\Pln'; % Folder onde serão salvas as PCS segmentadas com o ROI referente ao plano.
handles.path.PCCanais= '\Reg\cn'; % Folder onde serão salvas as PCS segmentadas com o ROI referente ao plano.
handles.path.PCFull= '\Reg\full'; % Folder onde serão salvas as PCs full, ou seja, concatenadas após o resgistro.

% Captura o número de folders contendo as PCs:
pathAux= sprintf('%s%s',handles.path.Base, handles.path.PC);
infoFolder= dir(pathAux);
handles.val.numFolders= nnz([infoFolder.isdir]) - 2;

% Definição de alguns nomes de arquivos:
handles.name.FolderBase= '\2022_11_25_01_';
handles.name.FileBase  = '\2022_11_25_01_';
handles.name.FileTForm = 'tform';
handles.name.FileDataInterferometro = '\interferometro_exp_01.mat';

% definição da extensão de alguns arquivos:
handles.name.extPC= 'pcd';

% Parametros que definem quantas PCs serão lidas por folder:
handles.val.fileIni= 3;
handles.val.fileEnd= 3;

% Parâmetros com flags para habilitar a exibição de dados:
handles.show.PC= 0;
handles.show.PCReg= 0;
handles.show.Data= 1;

% Flags que habilitam algumas funções: 
handles.hab.TesteRegistro= 1; % Habilita a variação dos parâmetros para teste de registro.
handles.hab.VariacaoMetricaRegistro= 0;

% Parametros para definição do algoritmo usado para o registro das PCS
handles.algorithm.Reg= 'ICP';

% Parametros para definição do algoritmo usado para subamostrar as PCS
handles.algorithm.SubSample= 'gridAverage';

% Parametro usado para fazer o merge das PCs
handles.val.mergeSize= 0.001;

% Parâmetros para avaliação dos algoritmos de registro:
handles.val.VariacaoGridSize= 10;
handles.val.VariacaoMetrica= 2;

% Parâmetros para efetuar o downSample da PC. No Matalab tem 3 métodos:
% 1) "pcdownsample(ptCloudIn,'random',percentage)", onde a escolha dos pontos
% segue um creitério aleatório. Usada apenas para pointo-a-ponto.
% 2) "pcdownsample(ptCloudIn,'gridAverage',gridStep)", faz uma subamostragem
% baseada num filtro especificado pelo grid de um 3D box, ou volume cúbico.
% Esta é usada tanto para ponto-a-ponto quanto ponto-a-plano.  
% 3) "pcdownsample(ptCloudIn,'nonuniformGridSample',maxNumPoints)", a
% filtragem é baseada num volume cubico também, porém o grid não é definido, 
% apenas a quantiade de pontos contida no volume.
% Também define a métrica do registro em função do algoritmo de
% subamostragem, se é ponto-a-ponto ou ponto-a-plano.
handles.val.percentage= 0.2;  % Usado no método 1- Percentual de redução da PC entre 0 e 1; 
handles.val.gridSizeIni= 0.1; % Usado no método 2- Define o grid do volume cúbico, 3D Box, em metros.
handles.val.maxNumPoints= 6;  % Usado no método 3- max. quantidadde de pontos para 3D Box, o mínimo é 6.

% Carrega os resultados de medição feitas diretamente no interferômetro
% que foram obtidos no experimento realizado no lab. do CERTI:
pathDataInterferomtero= sprintf('%s%s', handles.path.Base, handles.name.FileDataInterferometro);
handles.medicoes.Interferometro= load(pathDataInterferomtero);

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

% --- Executes on button press in btAplicaParametros.
function btAplicaParametros_Callback(hObject, eventdata, handles)
% hObject    handle to btAplicaParametros (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('path Base= %s', handles.basePath);

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

% Seleciona os parâmetros dos algoritmos de registro e de sub-amostragem em
% função da técnica utilizada pelo algoritmo de subamostragem:
switch (handles.algorithm.SubSample)
    case 'Random'
        handles.val.registerMetric='pointToPoint'; 
        handles.val.DownSampleIni= handles.val.percentage; 
    case 'gridAverage'
        handles.val.registerMetric='pointToPlane';
        handles.val.DownSampleIni= handles.val.gridSizeIni;
    case 'nonUniformGrid'
        handles.val.registerMetric='pointToPlane';
        handles.val.DownSampleIni= handles.val.maxNumPoints;
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


% --- Executes on button press in btPathBase.
function btPathBase_Callback(hObject, eventdata, handles)
% hObject    handle to btPathBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.basePath= uigetdir('Select a directory');
a=0;
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
