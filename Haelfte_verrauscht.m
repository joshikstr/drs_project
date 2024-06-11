% PCA wird angewandt auf ein Bild, das zur Haelfte verrauscht ist
% nach Ruecktransformation ist auch die urspruenglich nicht verrauschte Haelfte ein bisschen verrauscht
% -> Transformationsmatrix, die erstellt wird hat Auswirkungen auf das geamte Bild

%% init
clear 
clc

addpath data\
addpath functions\

imds = imageDatastore("data\images\");

%% bsp small dataset image 

% create dataMatrix

imgOrig1= readimage(imds,1);
imgOrig = imgOrig1; 


%Hälfte des Bildes verrauschen 
    image_double = im2double(imgOrig); 
    [rows, cols, channels] = size(image_double); 

    %nur die linke Hälfte verrauschen 
    left_half = image_double(:, 1:floor(cols/2), :); 
    varGauss = 0.02 * rand;
    noisy_left_half = imnoise(left_half, 'gaussian', varGauss);

    %rechte Hälfte unverändert lassen 
    right_half = image_double(:, floor(cols/2)+1:end, :); 

    %Beiden Hälften wieder zusammenführen 
    imgOrig = [noisy_left_half right_half];    
    imgOrig = im2uint8(imgOrig); 
  

%% Beginn Algorithmus 
dataMatrixNoise = [];
nImg = 50;


for img = 1:nImg  
    varGauss = 0.02 * rand;

    imgNoise = imnoise(imgOrig,'gaussian', varGauss);    
    dataMatrixNoise(img,:) = imgNoise(:);
end

sizeImage = size(imgOrig);


%% pca

[coeff, score, ~, ~, explained, mu] = pca(dataMatrixNoise);

threshold = 5; 
cumulativeExplained = cumsum(explained);
nComponents = find(cumulativeExplained >= threshold, 1);

pcaMatrix = score(:, 1:nComponents);
dataMatrixRecons = pcaMatrix * coeff(:, 1:nComponents)' + mu;

%% figures 

close all

idxRandImg = randi(nImg);

figure
imshow(imgOrig)

imgNoise = uint8(reshape(dataMatrixNoise(idxRandImg,:), sizeImage));
figure
imshow(imgNoise)

imgRecons = uint8(reshape(dataMatrixRecons(idxRandImg,:), sizeImage));
figure
imshow(imgRecons)


%% Korrelation Ursprungsbild und PCA

% Berechnung der Korrelation zwischen den beiden rekonstruierten Bildern
correlation = corr2(imgOrig1, imgRecons);

fprintf('Die Korrelation zwischen dem Originalbild und dem PCR-Bild beträgt: %.4f\n\n', correlation);


