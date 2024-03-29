function varargout = Registro_GUI(varargin)
%REGISTRO_GUI MATLAB code file for Registro_GUI.fig
%      REGISTRO_GUI, by itself, creates a new REGISTRO_GUI or raises the existing
%      singleton*.
%
%      H = REGISTRO_GUI returns the handle to a new REGISTRO_GUI or the handle to
%      the existing singleton*.
%
%      REGISTRO_GUI('Property','Value',...) creates a new REGISTRO_GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Registro_GUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      REGISTRO_GUI('CALLBACK') and REGISTRO_GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in REGISTRO_GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Registro_GUI

% Last Modified by GUIDE v2.5 31-Jan-2023 18:15:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Registro_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Registro_GUI_OutputFcn, ...
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


% --- Executes just before Registro_GUI is made visible.
function Registro_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Definição de alguns paths:
% Os únicos paths que precisam serem definidos são o handles.path.BaseRead e
% o handles.path.BaseSave:

pathInicial= 'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferometro\experimento_01\pcd';
handles.path.BaseRead= pathInicial; 
handles.path.BaseSave= "";

% Outros paths fixos, que são gerados automaticametne pelo programa:
handles.path.PCReg= '\out\pcReg'; % Folder onde serão salvas as PCs registradas
handles.path.PCCanais= '\out\pcRegPorCanal\cn'; % Folder onde serão salvas as PCS segmentadas com o ROI referente ao plano.
handles.path.PCFull= '\out\pcRegConcatenada'; % Folder onde serão salvas as PCs full, ou seja, concatenadas após o resgistro.
handles.path.tform= '\out\tform'; % Folder onde serão salvas as PCs full, ou seja, concatenadas após o resgistro.


% Definição de alguns nomes de arquivos:
handles.name.FolderBase= '\2022_11_25_01_';
handles.name.FileBase  = '\2022_11_25_01_';
handles.name.FileTForm = 'tform';
handles.name.referenceDataFile = "";


% definição da extensão de alguns arquivos:
handles.name.extPC= 'pcd';
handles.name.extDataFile= 'mat';

% Parametros que definem quantas PCs serão lidas por folder:
handles.val.PcIni= str2num(handles.editPcInicial.String); %3;
handles.val.PcFim= str2num(handles.editPcFinal.String); %3;

% Parâmetros com flags para habilitar a exibição de dados:
handles.show.PCReg= handles.rdExibeRegistro.Value;
handles.show.resultAnalise= handles.rdExibeResultadosAnalise.Value;


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
handles.val.numVariacaoGridSize= 10;
handles.val.VariacaoMetrica= 2;

% Flague que indica finalziação dos registros das PCs:
handles.registroFinalizado= 0;


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

handles.val.percentage= str2double(handles.txtPercentualReducaoDS.String); %0.2;  % Usado no método 1- Percentual de redução da PC entre 0 e 1; 
handles.val.gridSize= str2double(handles.txtGridSize.String); % Usado no método 2- Define o grid do volume cúbico, 3D Box, em metros.
handles.val.maxNumPoints= str2double(handles.txtMaxNumPoints.String); %6;  % Usado no método 3- max. quantidadde de pontos para 3D Box, o mínimo é 6.

handles.enable.SetPercentual= 'off';

% Choose default command line output for Registro_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes Registro_GUI wait for user response (see UIRESUME)
% uiwait(handles.panelBase);


% --- Outputs from this function are returned to the command line.
function varargout = Registro_GUI_OutputFcn(hObject, eventdata, handles)
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


% --- Executes on button press in btAnalisaRegistros.
function btAnalisaRegistros_Callback(hObject, eventdata, handles)
% hObject    handle to btAnalisaRegistros (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
close all;

msg= sprintf('Defina o arquivo .mat que contém os dados de referência.');
msgfig= msgbox(msg,'Atenção','warn');
uiwait(msgfig);

% Define o arquivo para carregar os dados de refência medidos pelo
% interferômetro:
fullFile= sprintf('%s\\*.%s', handles.path.BaseRead, handles.name.extDataFile); 
[handles.name.referenceDataFile handles.path.DataFile]= uigetfile(fullFile);

% Chama callback para realizar o testa de desempenho de registro: 
if (handles.registroFinalizado)
    if (handles.name.referenceDataFile~= "")
        fAnalisaRegistros(handles);
    else
        msg= sprintf('Antes de prosseguir defina o arquivo com dados de referência.');
        msgbox(msg, 'Error', 'error');
    end    
end

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


% --- Executes on button press in btRegistra.
function btRegistra_Callback(hObject, eventdata, handles)
% hObject    handle to btRegistra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Exibe mensagem:
msg= sprintf(' Carregando PCs no buffer.');
handles.editMsgs.String= msg;

answer = questdlg('Seleciona uma das opções abaixo', ...
	'Registro de nuvem de pontos', ...
	'Múltiplos folders', 'Arquivos .pcd','Múltiplos folders');
% Handle response
switch answer
    case 'Múltiplos folders'
        handles.multiplosFolders= 1;
        % Seleciona os folders que contém as PCs:
        handles.path.BaseRead= uigetdir(handles.path.BaseRead);
        if (handles.path.BaseRead==0)
            handles.editMsgs.String= "Path Inválido!!!!!";
            handles.editMsgs.ForegroundColor= [1, 0, 0];
        else
            msg= sprintf('Ler as PCs de: \n%s', handles.path.BaseRead);
            handles.editMsgs.String= msg;
            handles.editMsgs.ForegroundColor= [0, 0.447, 0.741];
        end
        
    case 'Arquivos .pcd'
        handles.multiplosFolders= 0;
        % Selciona as mmultiplas PCs:    
        fullFiles= sprintf('%s\\*.%s', handles.path.BaseRead, handles.name.extPC); 
        [handles.name.PCsFiles handles.path.BaseRead]= uigetfile(fullFiles, 'MultiSelect', 'on');
end

% Exibe mensagem:
msg= fprintf(' \n Carregando as PCs no buffer...');

% Carrega as PCs originais geradas no experimento:
handles= fCarregaPCs(handles);

msg= fprintf(' \n Efetuando o registro das PCs carregadas no Buffer...');

% Chama a função para registro das PCs:
handles= fRegistraPC(handles);

msg= fprintf(' \n Registro das PCs concluído.');

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
    fprintf('Valor do percentual de redução setado para -> %d\n', handles.val.percentage);
    % Update handles structure
    guidata(hObject, handles);    
else
    fprintf('Entre com um valor válido entre 0 e 1.\n');    
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
    fprintf('Entre com um valor válido maior que zero (>0).\n');    
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
    fprintf('Entre com um valor válido maior que zero (>0).\n');    
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

handles.path.BaseSave= uigetdir(handles.path.BaseSave);
if (handles.path.BaseSave==0)
    handles.staticPathSave.String= "Path Inválido!!!!!";
    handles.staticPathSave.ForegroundColor= [1, 0, 0];
else
    msg= sprintf('Salvar as PCs em: \n%s', handles.path.BaseSave);
    handles.staticPathSave.String= msg;
    handles.staticPathSave.ForegroundColor= [0, 0.447, 0.741];
    
    % Chama a função para salvar as PCs e tforms:
    fSalvaPCsRegistradas(handles);
end
% Update handles structure
guidata(hObject, handles);


function txtNumVariacoesGridSize_Callback(hObject, eventdata, handles)
% hObject    handle to txtNumVariacoesGridSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNumVariacoesGridSize as text
%        str2double(get(hObject,'String')) returns contents of txtNumVariacoesGridSize as a double
str= get(hObject,'String');
handles.val.numVariacaoGridSize= str2num(str);
if (handles.val.numVariacaoGridSize<1)
    set(hObject,'String', 'Null');
    set(hObject,'ForegroundColor', [1, 0, 0]);    
    msg= msgbox('Escolha um inteiro maior que zero.', 'Valor inválido!', 'error'); 
else
    set(hObject,'ForegroundColor', [0, 0.447, 0.741]);
end
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function txtNumVariacoesGridSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNumVariacoesGridSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
str= get(hObject,'String');
handles.val.numVariacaoGridSize= str2num(str);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btSair.
function btSair_Callback(hObject, eventdata, handles)
% hObject    handle to btSair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.panelBase.HandleVisibility= 'on';
close all;
clear;
clc;


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
function staticPathSave_CreateFcn(hObject, eventdata, handles)
% hObject    handle to staticPathSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'String', 'Salvar as PCs em:');


% --- Executes during object creation, after setting all properties.
function btRegistra_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btRegistra (see GCBO)
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


% --- Executes during object creation, after setting all properties.
function panelBase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to panelBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function editPcInicial_Callback(hObject, eventdata, handles)
% hObject    handle to editPcInicial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPcInicial as text
%        str2double(get(hObject,'String')) returns contents of editPcInicial as a double
str= get(hObject, 'String')
handles.val.PcIni= str2num(str);
if (handles.val.PcIni<1)
    set(hObject,'String', 'Null');
    set(hObject,'ForegroundColor', [1, 0, 0]);    
    msg= msgbox('Escolha um inteiro maior que zero.', 'Valor inválido!', 'error'); 
else
    set(hObject,'ForegroundColor', [0, 0.447, 0.741]);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editPcInicial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPcInicial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPcFinal_Callback(hObject, eventdata, handles)
% hObject    handle to editPcFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPcFinal as text
%        str2double(get(hObject,'String')) returns contents of editPcFinal as a double
str= get(hObject, 'String')
handles.val.PcFim= str2num(str);
if (handles.val.PcFim<1)
    set(hObject,'String', 'Null');
    set(hObject,'ForegroundColor', [1, 0, 0]);    
    msg= msgbox('Escolha um inteiro maior que zero.', 'Valor inválido!', 'error'); 
else
    set(hObject,'ForegroundColor', [0, 0.447, 0.741]);
end

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editPcFinal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPcFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in rdExibeRegistro.
function rdExibeRegistro_Callback(hObject, eventdata, handles)
% hObject    handle to rdExibeRegistro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rdExibeRegistro
val= get(hObject, 'Value');
handles.show.PCReg= val;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in rdExibeResultadosAnalise.
function rdExibeResultadosAnalise_Callback(hObject, eventdata, handles)
% hObject    handle to rdExibeResultadosAnalise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rdExibeResultadosAnalise

val= get(hObject, 'Value');
handles.show.resultAnalise= val;

% Update handles structure
guidata(hObject, handles);


function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to editMsgs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMsgs as text
%        str2double(get(hObject,'String')) returns contents of editMsgs as a double


% --- Executes during object creation, after setting all properties.
function editMsgs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMsgs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btSelecionaPCs.
function btSelecionaPCs_Callback(hObject, eventdata, handles)
% hObject    handle to btSelecionaPCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fullFiles= sprintf('%s\\*.%s', handles.path.BaseRead, handles.name.extPC); 
[handles.name.PCsFiles handles.path.BaseRead]= uigetfile(fullFiles, 'MultiSelect', 'on');

% Update handles structure
guidata(hObject, handles);


