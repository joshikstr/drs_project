
% unterschiedliches gaussches rauschen auf ein Bild 
% dann pca 

%% init
clear 
clc
close all

addpath data\
addpath functions\

imds = imageDatastore("data\images\");

%% bsp small dataset image 

% create dataMatrix

imgOrig = readimage(imds,1);
figure
imshow(imgOrig)
title("original image")

% noisy picture
imgOrig = imnoise(imgOrig, 'gaussian', 0.001);
figure
imshow(imgOrig)
title("noisy image")


%% algorithm starting here

% making different noise pictures
dataMatrixNoise = [];
nImg = 15;

for img = 1:nImg
    varGauss = 0.02 * rand;

    imgNoise = imnoise(imgOrig,'gaussian', varGauss);    
    dataMatrixNoise(img,:) = imgNoise(:);
end
for img = 1:nImg
    noiseDensity = 0.02 * rand;

    imgNoise = imnoise(imgOrig,'salt & pepper', noiseDensity);  
    img_idx=img+nImg;
    dataMatrixNoise(img_idx,:) = imgNoise(:);
end
for img = 1:nImg
    varSpeckle = 0.02 * rand;

    imgNoise = imnoise(imgOrig,'speckle', varSpeckle); 
    img_idx=img+2*nImg;
    dataMatrixNoise(img_idx,:) = imgNoise(:);
end

sizeImage = size(imgOrig);

%% pca

[coeff, score, latent, ~, explained, mu] = pca(dataMatrixNoise);

threshold = 5; 
cumulativeExplained = cumsum(explained);
nComponents = find(cumulativeExplained >= threshold, 1);

dataMatrixRecons = score(:, 1:nComponents) * coeff(:, 1:nComponents)'  + mu;

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


%Korrelation Ursprungsbild und PCA

% Berechnung der Korrelation zwischen den beiden rekonstruierten Bildern
correlation = corr2(imgOrig, imgRecons);

fprintf('Die Korrelation zwischen den beiden optimierten Bildern beträgt: %.4f\n\n', correlation);


%Rausch Index
% -> SNR misst die Qualität eines Signals im Allgemeinen, indem es das Verhältnis von Signalstärke zu Rauschstärke angibt.
% -> PSNR ist spezifisch für Bilder und Videos und vergleicht die Qualität eines rekonstruierten Bildes mit dem Originalbild durch das Verhältnis von maximaler Signalstärke zur mittleren quadratischen Abweichung.

%-> Ein höherer PSNR-Wert deutet auf eine höhere Qualität der rekonstruierten oder komprimierten Bilddaten hin, da der Fehler (Rauschen) im Vergleich zum Signal kleiner ist.

%Rausch Index Original Bild zu Noise Bild
[peaksnr, snr] = psnr(imgOrig, imgNoise); 
fprintf('Peak-SNR original Image zu noise Image:  %0.4f \n', peaksnr);
fprintf('SNR original Image zu noise Image:  %0.4f \n\n', snr);

%Rausch Index PCR-Bild zu Noise Bild
[peaksnr, snr] = psnr(imgRecons, imgNoise); 
fprintf('Peak-SNR PCA Image zu noise Image:  %0.4f \n', peaksnr);
fprintf('SNR PCA Image zu noise Image:  %0.4f \n\n', snr);


