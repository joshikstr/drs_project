
% unterschiedliches gaussches rauschen auf ein Bild 
% dann ica 

%% init
clear 
clc
close all

addpath data\
addpath functions\

imds = imageDatastore("data\images\");

%% bsp small dataset image 

% create dataMatrix

imgOrig1 = readimage(imds,1);

% adding noise to input image
imgOrig = imnoise(imgOrig1, 'gaussian', 0.001);


%% start of the alorithm
dataMatrixNoise = [];
nImg = 40;

for img = 1:nImg
    varGauss = 0.02 * rand;

    imgNoise = imnoise(imgOrig,'gaussian', varGauss);    
    dataMatrixNoise(img,:) = imgNoise(:);
end

sizeImage = size(imgOrig);


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



%Korrelation Ursprungsbild und ICA

% Berechnung der Korrelation zwischen den beiden rekonstruierten Bildern
correlation = corr2(imgOrig, imgRecons);

fprintf('Die Korrelation zwischen den beiden optimierten Bildern beträgt: %.4f\n\n', correlation);

correlation = corr2(imgOrig, imgRecons_inv);

fprintf('Die Korrelation zwischen den beiden optimierten Bildern (invertiert) beträgt: %.4f\n\n', correlation);

