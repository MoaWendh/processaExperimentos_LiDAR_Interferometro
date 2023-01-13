function varargout = analisePorCanal_GUI(varargin)
% ANALISEPORCANAL_GUI MATLAB code for analisePorCanal_GUI.fig
%      ANALISEPORCANAL_GUI, by itself, creates a new ANALISEPORCANAL_GUI or raises the existing
%      singleton*.
%
%      H = ANALISEPORCANAL_GUI returns the handle to a new ANALISEPORCANAL_GUI or the handle to
%      the existing singleton*.
%
%      ANALISEPORCANAL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALISEPORCANAL_GUI.M with the given input arguments.
%
%      ANALISEPORCANAL_GUI('Property','Value',...) creates a new ANALISEPORCANAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before analisePorCanal_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to analisePorCanal_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help analisePorCanal_GUI

% Last Modified by GUIDE v2.5 13-Jan-2023 19:23:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @analisePorCanal_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @analisePorCanal_GUI_OutputFcn, ...
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


% --- Executes just before analisePorCanal_GUI is made visible.
function analisePorCanal_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to analisePorCanal_GUI (see VARARGIN)

handles.statusProgram= 'Aguardando comando.'
handles.pathIni= 'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferometro\experimento_01\out\pcReg';

% Minhas variáveis e parâmetros:
handles.nameFolderToSaveCn= 'porCanal\separado\cn';
handles.nameFolderToSaveSeg= 'porCanal\segmentado\cn';

handles.extPC= 'pcd';

% Choose default command line output for analisePorCanal_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes analisePorCanal_GUI wait for user response (see UIRESUME)
% uiwait(handles.baseFigure);


% --- Outputs from this function are returned to the command line.
function varargout = analisePorCanal_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbExecutaAnalise.
function pbExecutaAnalise_Callback(hObject, eventdata, handles)
% hObject    handle to pbExecutaAnalise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fAnaliseCanais(handles);




% --- Executes on button press in pushSair.
function pushSair_Callback(hObject, eventdata, handles)
% hObject    handle to pushSair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.baseFigure.HandleVisibility= 'on';
close all;


% --- Executes on button press in pbSeparaCanais.
function pbSeparaCanais_Callback(hObject, eventdata, handles)
% hObject    handle to pbSeparaCanais (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Define a(s) PC(s) cujos canais serão separados:
path= sprintf('%s%s', handles.pathIni,'\*.pcd');
[handles.fileSeparar, handles.path]= uigetfile(path,'MultiSelect', 'on');
if (handles.path==0)
    handles.statusProgram= "Path Inválido!!!!!";
    handles.staticShowStatusSepara.String= handles.statusProgram; 
    handles.staticShowStatusSepara.ForegroundColor= [1, 0, 0];
    % Exibe msg de erro:
    msgbox('Path inválido!!!!', 'error');
else 
    handles.statusProgram= 'Separando canais...';
    handles.staticShowStatusSepara.String= handles.statusProgram; 
    handles.staticShowStatusSepara.ForegroundColor= [0.467, 0.675, 0.188];
    % Chama a função principal que irá separar os canais:
    handles= fSeparaCanais(handles);
    handles.staticShowStatusSepara.String= handles.statusProgram;
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in chkEscolherCanalSequencia.
function chkEscolherCanalSequencia_Callback(hObject, eventdata, handles)
% hObject    handle to chkEscolherCanalSequencia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkEscolherCanalSequencia


function editCanalSemSequencia_Callback(hObject, eventdata, handles)
% hObject    handle to editCanalSemSequencia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCanalSemSequencia as text
%        str2double(get(hObject,'String')) returns contents of editCanalSemSequencia as a double

% Obs.: A entrada dos canais pode ser feita de três formas:
% 1ª) Na sequência separados por ":", exemplo: 1:16, 5:10, 15:16;
% 2º) Mais de um canal sem sequência separados por ",", exemplo: 3, 5, 7;
% 3ª) Individulamente, exemplo: 9;

handles.cnSepara= str2num(hObject.String);
handles.valMax= max(handles.cnSepara);
handles.valMin= min(handles.cnSepara);
if (handles.valMax>16 || handles.valMin<1)
    hObject.String= 'Erro! Val. inválido: (>1 e <16)';
    hObject.ForegroundColor= [1, 0, 0];
    f = msgbox('Valor inválido!!', 'Error','error');
else
    hObject.ForegroundColor= [0, 0.447, 0.471];   
    handles.staticValValidosParaAnalise.String= hObject.String;
    handles.staticValValidosParaSegmentacao.String= hObject.String;
    handles.editSelecionaCanalParaSegmentacao.String= hObject.String;
    handles.editSelecionaCanalParaAnalise.String= hObject.String;
end

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editCanalSemSequencia_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCanalSemSequencia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.cnSepara= str2num(hObject.String);
handles.valMax= max(handles.cnSepara);
handles.valMin= min(handles.cnSepara);

% Update handles structure
guidata(hObject, handles);



function editSelecionaCanalParaAnalise_Callback(hObject, eventdata, handles)
% hObject    handle to editSelecionaCanalParaAnalise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSelecionaCanalParaAnalise as text
%        str2double(get(hObject,'String')) returns contents of editSelecionaCanalParaAnalise as a double

handles.cnAnalise= str2num(hObject.String);
valMaxAux= max(handles.cnAnalise);
valMinAux= min(handles.cnAnalise);
if (valMinAux<handles.valMin || valMaxAux>handles.valMax)
    hObject.String= 'Erro! Val. inválido.';
    hObject.ForegroundColor= [1, 0, 0];
    f = msgbox('Valor inválido!!', 'Error','error');
else
    hObject.ForegroundColor= [0, 0.447, 0.471];   
end

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editSelecionaCanalParaAnalise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSelecionaCanalParaAnalise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbSegmentaCanal.
function pbSegmentaCanal_Callback(hObject, eventdata, handles)
% hObject    handle to pbSegmentaCanal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Define a(s) PC(s) cujos canais serão separados:
path= sprintf('%s%s', handles.pathIni,'\*.pcd');
[handles.fileSegmentar, handles.path]= uigetfile(path,'MultiSelect', 'on');
if (handles.path==0)
    handles.statusProgram= "Path Inválido!!!!!";
    handles.staticShowStatusSegmenta.String= handles.statusProgram;
    handles.staticShowStatusSegmenta.ForegroundColor= [1, 0, 0];
    % Exibe msg de erro:
    msgbox('Path inválido!!!!', 'error');
else 
    handles.statusProgram= "Segmentando...";
    handles.staticShowStatusSegmenta.String= handles.statusProgram;
    handles.staticShowStatusSegmenta.ForegroundColor= [0.467, 0.675, 0.188];
    % Chama a função principal que irá separar os canais:
    handles= fSegmentaPCPorCanal(handles);
end

% Update handles structure
guidata(hObject, handles);




function editSelecionaCanalParaSegmentacao_Callback(hObject, eventdata, handles)
% hObject    handle to editSelecionaCanalParaSegmentacao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSelecionaCanalParaSegmentacao as text
%        str2double(get(hObject,'String')) returns contents of editSelecionaCanalParaSegmentacao as a double
handles.cnSegmenta= str2num(hObject.String);
valMaxAux= max(handles.cnSegmenta);
valMinAux= min(handles.cnSegmenta);
if (valMinAux<handles.valMin || valMaxAux>handles.valMax)
    hObject.String= 'Erro! Val. inválido.';
    hObject.ForegroundColor= [1, 0, 0];
    f = msgbox('Valor inválido!!', 'Error','error');
else
    hObject.ForegroundColor= [0, 0.447, 0.471];   
end

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editSelecionaCanalParaSegmentacao_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSelecionaCanalParaSegmentacao (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.cnSegmenta= str2num(hObject.String);

% Update handles structure
guidata(hObject, handles);
