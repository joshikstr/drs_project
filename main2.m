
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
correlation = corr2(imgOrig, imgRecons);

fprintf('Die Korrelation zwischen dem Oridinalbild und dem PCR-Bild beträgt: %.4f\n\n', correlation);


%% Rausch Index

% -> PSNR ist spezifisch für Bilder und Videos und vergleicht die Qualität eines rekonstruierten Bildes mit dem Originalbild durch das Verhältnis von maximaler Signalstärke zur mittleren quadratischen Abweichung.

%-> Ein höherer PSNR-Wert deutet auf eine höhere Qualität der rekonstruierten oder komprimierten Bilddaten hin, da der Fehler (Rauschen) im Vergleich zum Signal kleiner ist.

%Rausch Index Original Bild zu Noise Bild
peaksnr = psnr(imgOrig, imgNoise); 
fprintf('Peak-SNR original Image zu noise Image:  %0.4f dB\n', peaksnr);

%Rausch Index PCR-Bild zu Noise Bild
peaksnr = psnr(imgRecons, imgNoise); 
fprintf('Peak-SNR PCA Image zu noise Image:  %0.4f dB\n', peaksnr);


%% SSIM   -> macht für uns wenig bis keinen Sinn

%SSIM ist ein Maß, das die strukturelle Ähnlichkeit zwischen zwei Bildern bewertet. Es berücksichtigt Helligkeit, Kontrast und Struktur. SSIM-Werte liegen im Bereich von -1 bis 1, wobei 1 eine perfekte Übereinstimmung bedeutet.

ssimval = ssim(imgOrig,imgNoise);
fprintf('SSIM original Image zu noise Image:  %0.4f \n', ssimval);


ssimval = ssim(imgRecons,imgNoise);
fprintf('SSIM PCA Image zu noise Image:  %0.4f \n', ssimval);
