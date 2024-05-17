
% gleiches gaussches rauschen auf datensatz 
% dann pca 

%% init
clear 
clc

addpath data\
addpath functions\

imds = imageDatastore("data\images\");

%% bsp small dataset image 

% create dataMatrix

dataMatrixOrig = [];
dataMatrixNoise = [];
nImg = 100;

for img = 1:nImg
    imgOrig = readimage(imds,img);

    try 
        dataMatrixOrig(img,:) = imgOrig(:);
    catch 
         imgOrig = rgb2gray(imgOrig);
         dataMatrixOrig(img,:) = imgOrig(:);
    end

    imgNoise = imnoise(imgOrig,'gaussian', 0.1);    
    dataMatrixNoise(img,:) = imgNoise(:);
end

sizeImage = size(imgOrig);

%% pca

[coeff, score, ~, ~, explained, mu] = pca(dataMatrixNoise);

threshold = 80; 
cumulativeExplained = cumsum(explained);
nComponents = find(cumulativeExplained >= threshold, 1);

pcaMatrix = score(:, 1:nComponents);
dataMatrixRecons = pcaMatrix * coeff(:, 1:nComponents)' + mu;

%% figures 

close all

idxRandImg = randi(nImg);
idxRandImg = 1;

imgOrig = uint8(reshape(dataMatrixOrig(idxRandImg,:), sizeImage));
figure
imshow(imgOrig)

imgNoise = uint8(reshape(dataMatrixNoise(idxRandImg,:), sizeImage));
figure
imshow(imgNoise)

imgRecons = uint8(reshape(dataMatrixRecons(idxRandImg,:), sizeImage));
figure
imshow(imgRecons)