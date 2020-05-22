function varargout = mainPrg(varargin)
% MAINPRG MATLAB code for mainPrg.fig
%      MAINPRG, by itself, creates a new MAINPRG or raises the existing
%      singleton*.
%
%      H = MAINPRG returns the handle to a new MAINPRG or the handle to
%      the existing singleton*.
%
%      MAINPRG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINPRG.M with the given input arguments.
%
%      MAINPRG('Property','Value',...) creates a new MAINPRG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainPrg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainPrg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainPrg

% Last Modified by GUIDE v2.5 20-May-2020 16:35:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainPrg_OpeningFcn, ...
                   'gui_OutputFcn',  @mainPrg_OutputFcn, ...
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


% --- Executes just before mainPrg is made visible.
function mainPrg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainPrg (see VARARGIN)

% Choose default command line output for mainPrg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainPrg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mainPrg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global originalImage im2 path
[path,user_cance]=imgetfile();
if user_cance
    msgbox(sprintf('Error'),'Error','Error');
    return
end
originalImage=imread(path);
originalImage=im2double(originalImage);
im2=originalImage;
axes(handles.axes1);
imshow(originalImage);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%SVM button
tic;
global originalImage num_clus_som
I = imresize(originalImage,0.5);
cform = makecform('srgb2lab');
lab_I = applycform(I,cform);
ab = double(lab_I(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
a = ab(:,1);
b = ab(:,2);
normA = (a-min(a(:))) ./ (max(a(:))-min(a(:)));
normB = (b-min(b(:))) ./ (max(b(:))-min(b(:)));
ab = [normA normB];
newnRows = size(ab,1);
newnCols = size(ab,2);

num_clus=get(handles.edit1,'String');
while isempty(num_clus)
    msgbox('Enter cluster numbers');
end
num_clus_som=str2num(num_clus);


if num_clus_som==0
    msgbox('Invalid cluster number');
else
    disp(num_clus_som);
    if num_clus_som>3 
        msgbox('The best cluster number for SOM is 3. Or its segementation result is not good.');
    end
    cluster=num_clus_som;
    
    disp('Cluster');
    disp(cluster);
%cluster = 3;
% Max number of iteration
N = 90;
% initial learning rate
eta = 0.3;
% exponential decay rate of the learning rate
etadecay = 0.2;
%random weight

w = rand(2,cluster);
%initial D
D = zeros(1,cluster);
% initial cluster index
clusterindex = zeros(newnRows,1);
% start 
for t = 1:N
     
   for data = 1 : newnRows
       for c = 1 : cluster
           D(c) = sqrt(((w(1,c)-ab(data,1))^2) + ((w(2,c)-ab(data,2))^2));
       end
       %find best macthing unit
       [~, bmuindex] = min(D);
       clusterindex(data)=bmuindex;

       %update weight
       oldW = w(:,bmuindex);
       new = oldW +  eta * (reshape(ab(data,:),2,1)-oldW);
       w(:,bmuindex) = new;

   end
   % update learning rate
   eta= etadecay * eta;
   %disp('In iteration');
   %disp(t);
   %disp('Learning rate');disp(eta);
end

%Label Every Pixel in the Image Using the Results from KMEANS
pixel_labels = reshape(clusterindex,nrows,ncols);
%Create Images that Segment the I Image by Color.
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);

for k = 1:cluster
    color = I;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end

axes(handles.axes2);
imshow(segmented_images{cluster});

% for j=1:cluster
%     cluster_name=strcat('Cluster ',num2str(j));
%     figure();imshow(segmented_images{j}); title(cluster_name');
% end
% subplot(221); imshow(originalImage); title('originalImage')
% subplot(222); imshow(segmented_images{1}); title('objects in cluster 1')
% subplot(223); imshow(segmented_images{2}); title('objects in cluster 2')
% subplot(224); imshow(segmented_images{3}); title('objects in cluster 3')

disp('Finished SOM segmentation');
disp('SVM total processing time ');

time_value=num2str(toc);
show_time=strcat('Processing time of SOM (second)  = ',time_value);
toc;
set(handles.text3,'string',show_time);
number_som_value=strcat('Number of Clusters=',num2str(cluster));
set(handles.text5,'string',number_som_value);
set(handles.text3, 'Visible', 'on');
set(handles.text5, 'Visible', 'on');

clearvars
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic;
global path

%% check input
num_clus=get(handles.edit2,'String');
while isempty(num_clus)
    msgbox('Enter cluster numbers');
end
num_clus_kmeans=str2num(num_clus);


if num_clus_kmeans==0
    msgbox('Invalid cluster number');
else
    if num_clus_kmeans>8 
        msgbox('Maximum 8 cluster is recommended. Larger 8 will take too much processing time.');
    end
    K=num_clus_kmeans;

%% Load Image
I = im2double(imread(path));                % Load Image
I = imresize(I,0.5);
F = reshape(I,size(I,1)*size(I,2),3);                 % Color Features
%% K-means

%K     = 3;                                            % Cluster Numbers
CENTS = F( ceil(rand(K,1)*size(F,1)) ,:);             % Cluster Centers
DAL   = zeros(size(F,1),K+2);                         % Distances and Labels
KMI   = 10;                                           % K-means Iteration
for n = 1:KMI
    disp('In K-means iteration');
       disp(n);
   for i = 1:size(F,1)
      for j = 1:K  
        DAL(i,j) = norm(F(i,:) - CENTS(j,:));      
      end
      [Distance, CN] = min(DAL(i,1:K));               % 1:K are Distance from Cluster Centers 1:K 
      DAL(i,K+1) = CN;                                % K+1 is Cluster Label
      DAL(i,K+2) = Distance;                          % K+2 is Minimum Distance
      %disp('Distance');
      %disp(Distance);
      %disp('cluster label');
      %disp(CN);
   end
   for i = 1:K
       disp('In cluster');
       disp(i);
      A = (DAL(:,K+1) == i);                          % Cluster K Points
      CENTS(i,:) = mean(F(A,:));                      % New Cluster Centers
      if sum(isnan(CENTS(:))) ~= 0                    % If CENTS(i,:) Is Nan Then Replace It With Random Point
         NC = find(isnan(CENTS(:,1)) == 1);           % Find Nan Centers
         for Ind = 1:size(NC,1)
         CENTS(NC(Ind),:) = F(randi(size(F,1)),:);
         end
      end
   end
end

X = zeros(size(F));
for i = 1:K
idx = find(DAL(:,K+1) == i);
X(idx,:) = repmat(CENTS(i,:),size(idx,1),1); 
end
T = reshape(X,size(I,1),size(I,2),3);
%% Show
% figure()
% subplot(121); imshow(I); title('original')
% subplot(122); imshow(T); title('segmented')
% disp('number of segments ='); disp(K)

set(handles.text6, 'Visible', 'on');
set(handles.text7, 'Visible', 'on');

disp('Finished K-means segmentation');
disp('K-means total processing time ');
toc;
time_value=num2str(toc);
show_time=strcat('Processing time of K-means (seconds) = ',time_value);
set(handles.text6,'string',show_time);
number_kmeans_value=strcat('Number of Clusters=',num2str(K));
set(handles.text7,'string',number_kmeans_value);

axes(handles.axes3);
imshow(T);

clearvars

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



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
arrayfun(@cla,findall(0,'type','axes'))


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close mainPrg;
