function varargout = interfaz(varargin)
% INTERFAZ MATLAB code for interfaz.fig
%      INTERFAZ, by itself, creates a new INTERFAZ or raises the existing
%      singleton*.
%
%      H = INTERFAZ returns the handle to a new INTERFAZ or the handle to
%      the existing singleton*.
%
%      INTERFAZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFAZ.M with the given input arguments.
%
%      INTERFAZ('Property','Value',...) creates a new INTERFAZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interfaz_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interfaz_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interfaz

% Last Modified by GUIDE v2.5 28-Feb-2017 13:30:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interfaz_OpeningFcn, ...
                   'gui_OutputFcn',  @interfaz_OutputFcn, ...
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


% --- Executes just before interfaz is made visible.
function interfaz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interfaz (see VARARGIN)

% Choose default command line output for interfaz
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes interfaz wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%I = imread('FIGURAS GEOMETRICAS.jpg');


vid=videoinput('winvideo',1,'RGB24_640x480');
%vid=videoinput('winvideo',2,'MJPG_1280x720'); %variables para capturar video desde la c�mara
vid.FramesPerTrigger=1; %n�mero de frames
vid.ReturnedColorspace='rgb'; %tipo de color del video
triggerconfig(vid,'manual'); 
vidRes=get(vid,'VideoResolution');
imWidth = vidRes(1);
imHeight = vidRes(2);
nBands = get(vid, 'NumberOfBands');
hImage = image(zeros(imHeight, imWidth, nBands), 'parent', handles.original);
preview(vid, hImage);

modulo_b = Bluetooth('HC-05',1);
fopen(modulo_b);

handles.bluetooth=modulo_b;

handles.img=vid;
guidata(hObject,handles);

% --- Outputs from this function are returned to the command line.
function varargout = interfaz_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in empezar.
function empezar_Callback(hObject, eventdata, handles)
% hObject    handle to empezar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%I = imread('FIGURAS GEOMETRICAS.jpg');
vid=handles.img;


bluetooth = handles.bluetooth;
I=getsnapshot(vid);
figure(1);
imshow(I)
hsv = rgb2hsv(I);

h = hsv(:,:,1);

contents = get(handles.color,'String'); 
v = contents{get(handles.color,'Value')};

if strcmp(v,'Rojo')
    h(h<0.001)=0;
    h(h>0.041)=0;%lo que no est� entre estos rangos se vuelve ceros
    h(h>0)=1;
elseif strcmp(v,'Verde')
    h(h<0.181)=0;
    h(h>0.230)=0;
    h(h>0.1)=1;
elseif strcmp(v,'Azul')
    h(h<0.625)=0;
    h(h>0.665)=0;
    h(h>0.1)=1;
end

h=imfill(h,'holes');
 

ee = strel('square',3);
b=imdilate(h,ee);
cantidad = 6;
if strcmp(v,'Verde')
    cantidad = 10;
end
for i=1:cantidad
    b=imerode(b,ee);
end


%get outlines of each object
[B,L,N] = bwboundaries(b);


%get stats
stats=  regionprops(L, 'Centroid', 'Area', 'Perimeter');
Centroid = cat(1, stats.Centroid);
Perimeter = cat(1,stats.Perimeter);
Area = cat(1,stats.Area);
CircleMetric = (Perimeter.^2)./(4*pi*Area);  %circularity metric

SquareMetric = NaN(N,1);
TriangleMetric = NaN(N,1);

encontro = false;
for k=1:N,
   %display metric values and which shape next to object
   cellsz = cellfun(@size,B(k),'uni',false);
   if (Area(k)>100 && cellsz{:}(1)>100)
       encontro = true;
   end
end

if encontro
    %for each boundary, fit to bounding box, and calculate some parameters
    for k=1:N,
       boundary = B{k};
       [rx,ry,boxArea] = minboundrect( boundary(:,2), boundary(:,1));  %x and y are flipped in images
       %get width and height of bounding box
       width = sqrt( sum( (rx(2)-rx(1)).^2 + (ry(2)-ry(1)).^2));
       height = sqrt( sum( (rx(2)-rx(3)).^2+ (ry(2)-ry(3)).^2));
       aspectRatio = width/height;
       if aspectRatio > 1,  
           aspectRatio = height/width;  %make aspect ratio less than unity
       end
       SquareMetric(k) = aspectRatio;    %aspect ratio of box sides
       TriangleMetric(k) = Area(k)/boxArea;  %filled area vs box area
    end

    %define some thresholds for each metric
    %do in order of circle, triangle, square, rectangle to avoid assigning the
    %same shape to multiple objects
    isCircle =   (CircleMetric < 1.4);
    isTriangle = ~isCircle & (TriangleMetric < 0.6);
    isSquare =   ~isCircle & ~isTriangle & (SquareMetric > 0.9);
    isRectangle= ~isCircle & ~isTriangle & ~isSquare;  %rectangle isn't any of these
    %assign shape to each object
    whichShape = cell(N,1);  
    whichShape(isCircle) = {'Circulo'};
    whichShape(isTriangle) = {'Triangulo'};
    whichShape(isSquare) = {'Cuadrado'};
    whichShape(isRectangle)= {'Rectangulo'};

    contents1 = get(handles.forma,'String'); 
    f = contents1{get(handles.forma,'Value')};
    encontro = false;
    mayor=0;
    for k=1:N,
       cellsz = cellfun(@size,B(k),'uni',false);
       if (strcmp(whichShape{k},f) && Area(k)>100)
           encontro = true;
           if (mayor < cellsz{:}(1))
               k1=k;
               mayor=cellsz{:}(1);
           end
       end
    end
    %now label with results
    RGB = label2rgb(L);
    if ~encontro
        RGB(RGB<255)=255;
        S = 'No se encontro ningun elemento con dicho color, por favor verifique tanto el color como la forma';
        set(handles.text3,'string',char(S))
    else
           a = num2str(Centroid(k1,1));
           b = num2str(Centroid(k1,2));
           angulo = 0;
           if (a < 220)
               angulo = 10;
           else if (a < 353)
                   angulo = 20;
               else if (a < 460)
                       angulo = 30;
                   else if (a < 590)
                           angulo = 40;
                       end
                   end
               end
           end
           
           fwrite(bluetooth, angulo);
           S = ['La coordenada x es: ' a ' y la coordenada y es: ' b ];
           set(handles.text3,'string',char(S))
    end
else
    RGB = label2rgb(L);
    RGB(RGB<255)=255;
    S = 'No se encontro ningun elemento';
    set(handles.text3,'string',char(S))
end

axes(handles.resultado);
imshow(RGB); hold on;impixelinfo;


% --- Executes on selection change in forma.
function forma_Callback(hObject, eventdata, handles)
% hObject    handle to forma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns forma contents as cell array
%        contents{get(hObject,'Value')} returns selected item from forma


% --- Executes during object creation, after setting all properties.
function forma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to forma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color.
function color_Callback(hObject, eventdata, handles)
% hObject    handle to color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color


% --- Executes during object creation, after setting all properties.
function color_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
