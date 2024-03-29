%% Segmentation by retrieval with guided random walks: 
%  Application to left ventricle segmentation in MRI
%  d'après A. Eslami, A. Karamalis, A. Katouzian, N. Navab

%% Rozand, Sarrazin, Sivera
%  2014.11.18

%% Hypothèses
%   - 3D images
%   - drivers are in a nx(sz) matrix
%   - patient image is of size sz, 
%   - myocardia have the same center and their sizes are normalized
%   - same mean in each image

%% Paramètres
Dice_threshold=0.25; 
seg_threshold=0.43; % Threshold to turn the result into binaries

alpha = 15;
beta  = 25;
gamma = 4;


%% Lecture des données :
% drivers : R, B,
% patient à segmenter : I, B0 et seeds
load('data.mat'); 
seeds=round(seeds);
sz=size(R);
sz=sz(2:end);


% Visualisation
% plot_seeds(I,seeds);

%% Initialisation
D_max=-1;
indx=-1;
X_opt=zeros(sz);

% ROI -- NOT DONE

%% Main loop on drivers
for k=1:size(R,1)
    R_k=squeeze(R(k,:,:,:));
    B_k=squeeze(B(k,:,:,:));
    X_k=Guided_Random_Walks(I,R_k,B_k,seeds,alpha,beta,gamma);
    D_k=Dice(X_k,B_k);
    
    if D_k>D_max
        D_max=D_k;
        indx=k;
        X_opt=X_k;
    end
    fprintf(['Dice index with driver ',int2str(k),': ',num2str(D_k),'\n\n']);   
end
 

if D_max>Dice_threshold
    fprintf(['\nBest segmentation with driver ',int2str(indx),'\nDice metric=',num2str(D_max),'\n'])
else
    fprintf('No matching subject found\nPerforming conventional Random Walks\n');
    X_rw=Random_Walks(I,seeds,alpha);  
    X_opt=X_rw;
end


%% Validation
B1=1*(X_opt>seg_threshold);

%show_boundaries(I,B0,B1);
%show_boundaries(I,squeeze(B(indx,:,:,:)),B1);

% volume w
v0=sum(B0(:));
v1=sum(B1(:));
fprintf(['Relative volume error: ',num2str((v1-v0)/v0),'\n']);

% Dice
d01=Dice(B0,B1);
fprintf(['Dice index ',num2str(d01),'\n']);

% shape similarity
addpath(genpath('toolbox_fm'));
S = similarity_shape(B0,B1);


