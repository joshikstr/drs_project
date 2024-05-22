
% unterschiedliches gaussches rauschen auf ein Bild 
% dann pca 

%% init
clear 
clc

addpath data\
addpath functions\

imds = imageDatastore("data\images\");

%% bsp small dataset image 

% create dataMatrix

imgOrig = readimage(imds,1);

imgOrig = imnoise(imgOrig, 'gaussian', 0.001);

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
fprintf('Peak-SNR original Image zu noise Image:  %0.4f \n', peaksnr);
fprintf('SNR original Image zu noise Image:  %0.4f \n\n', snr);


