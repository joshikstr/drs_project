% ICA wird auf einem Teil des Bildes angewandt
% dazu wird dieser Teil als Input fuer die ICA verschieden verrauscht
% die erhaltene Transformationsmatrix kann auf das gesamte Bild angewandt werden

%% init
clear 
clc
close all

addpath data\
addpath functions\

imds = imageDatastore("data\images\");

%% create dataset of images

imgOrig = readimage(imds,1);
imgOrig1 = imgOrig; 
sizeImageOrig = size(imgOrig);
% adding noise to input image
imgOrig = imnoise(imgOrig, 'gaussian', 0.001);

windowSize = 200;
imgWindow = imgOrig(1:windowSize,1:windowSize);

%% start of the alorithm
dataMatrixNoise = [];
nImg = 40;

for img = 1:nImg
    varGauss = 0.02 * rand;

    imgNoise = imnoise(imgWindow,'gaussian', varGauss);    
    dataMatrixNoise(img,:) = imgNoise(:);
end

sizeImage = size(imgWindow);


% passende Matrix erstellen um nachher aufs ganze Bild zurückrechnen zu
% können
dataMatrixOrig = [];
for i=1:nImg
    dataMatrixOrig(i,:)=imgOrig(:);
end
%% ica

[icasig, A_est, W]=fastica(dataMatrixNoise);

% rescaling
minlim=min(icasig');
rangelim=max(icasig')-minlim;
icasig=(icasig-minlim'*ones(1,size(icasig,2)))*255./(rangelim'*ones(1,size(icasig,2)));




%% figures 

close all

idxRandImg = randi(nImg);

figure
imshow(imgOrig)

imgNoise = uint8(reshape(dataMatrixNoise(idxRandImg,:), sizeImage));


imgRecons = uint8(reshape(icasig(1,:), sizeImage));

% inverting the image if necessary
imgRecons_inv = 255-imgRecons;

figure
for i=1:nImg
    subplot(1,nImg,i)
    imshow(uint8(reshape(dataMatrixNoise(i,:), sizeImage)));
end

figure
for i=1:nImg
    subplot(1,nImg,i)
    imshow(uint8(reshape(icasig(i,:), sizeImage)));
end

figure
imshow(imgRecons)

figure
imshow(imgRecons_inv)

%% zurückrechnen auf ganzes Bild

[icasig, A_est, W]=fastica(dataMatrixNoise);


icasig_new=W*dataMatrixOrig;

% rescaling
minlim=min(icasig_new');
rangelim=max(icasig_new')-minlim;
icasig_new=(icasig_new-minlim'*ones(1,size(icasig_new,2)))*255./(rangelim'*ones(1,size(icasig_new,2)));


reconsImg = uint8(reshape(icasig_new(i,:), sizeImageOrig));
figure
imshow(reconsImg);

% invert if necessary
imgRecons_inv = 255-reconsImg;

figure
imshow(imgRecons_inv)


% %% Korrelation Ursprungsbild und ICA
% 
% % Berechnung der Korrelation zwischen den beiden rekonstruierten Bildern
correlation = corr2(imgOrig1, imgRecons);

fprintf('Die Korrelation zwischen den beiden optimierten Bildern beträgt: %.4f\n\n', correlation);

correlation = corr2(imgOrig1, imgRecons_inv);

fprintf('Die Korrelation zwischen den beiden optimierten Bildern (invertiert) beträgt: %.4f\n\n', correlation);

