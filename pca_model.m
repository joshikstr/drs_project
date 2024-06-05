
% PCA-Modell erstellen: coeff und mu von Thorax berechnen und damit auf ein
% einzelnes Bild Rückschlüsse ziehen

%% init
clear 
clc
close all

addpath data\
addpath functions\

imds = imageDatastore("data\images\");

%% bsp small dataset image 

% create dataMatrix
images = 20;
dataMatrixNoise = [];
nImg = 5;
img_idx = 1;
for imgs = 1:images

    imgOrig = readimage(imds,imgs);
    % figure
    % imshow(imgOrig)
    % title("original image " + imgs)

    % making different noise pictures    
    for img = 1:nImg
        varGauss = 0.02 * rand;
    
        imgNoise = imnoise(imgOrig,'gaussian', varGauss);   
        img_idx = img_idx +1;

        try 
            dataMatrixNoise(img_idx,:) = imgNoise(:);
        catch 
             imgNoise = rgb2gray(imgNoise);
             dataMatrixNoise(img_idx,:) = imgNoise(:);
        end
    end
    for img = 1:nImg
        noiseDensity = 0.02 * rand;
    
        imgNoise = imnoise(imgOrig,'salt & pepper', noiseDensity);  
        img_idx=img_idx +1;
        try 
            dataMatrixNoise(img_idx,:) = imgNoise(:);
        catch 
             imgNoise = rgb2gray(imgNoise);
             dataMatrixNoise(img_idx,:) = imgNoise(:);
        end
    end
    for img = 1:nImg
        varSpeckle = 0.02 * rand;
    
        imgNoise = imnoise(imgOrig,'speckle', varSpeckle); 
        img_idx=img_idx +1;
        try 
            dataMatrixNoise(img_idx,:) = imgNoise(:);
        catch 
             imgNoise = rgb2gray(imgNoise);
             dataMatrixNoise(img_idx,:) = imgNoise(:);
        end
    end
end

sizeImage = size(imgOrig);

%% pca

[coeff, score, latent, ~, explained, mu] = pca(dataMatrixNoise);

threshold = 50; 
cumulativeExplained = cumsum(explained);
nComponents = find(cumulativeExplained >= threshold, 1);

red_score = score(:, 1:nComponents);
dataMatrixRecons = red_score * coeff(:, 1:nComponents)'  + mu;




%% figures 

idxRandImg = randi(nImg*3);


imgNoise = uint8(reshape(dataMatrixNoise(idxRandImg,:), sizeImage));
figure
imshow(imgNoise)
title("random noisy image (number: " + idxRandImg + ")")

imgRecons = uint8(reshape(dataMatrixRecons(idxRandImg,:), sizeImage));
figure
imshow(imgRecons)
title("reconstructed image after pca")

%% new image

img2 = readimage(imds,16);
figure
imshow(img2)
title("second image")

% noisy picture
img2 = imnoise(img2, 'gaussian', 0.001);
figure
imshow(img2)
title("noisy image")

img2_datenraum = [];
img2_datenraum(1,:) = img2(:);

red_coeff = coeff(:, 1:nComponents);

img2_pca_raum = (img2_datenraum - mu) * red_coeff;

% Rücktransformation
img2_recons = img2_pca_raum * red_coeff'  + mu;

imgRecons2 = uint8(reshape(img2_recons, sizeImage));
figure
imshow(imgRecons2)
title("new reconstructed image after pca")

%% Werte
%Korrelation Ursprungsbild und PCA

% Berechnung der Korrelation zwischen den beiden rekonstruierten Bildern
correlation = corr2(imgOrig, imgRecons);

fprintf('Die Korrelation zwischen den beiden optimierten Bildern beträgt: %.4f\n\n', correlation);



