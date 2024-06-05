
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


sizeImage = size(imgOrig);

dataMatrixSplit = [];

small_window1 = imgOrig(1:sizeImage(1)/2,1:sizeImage(2)/2);
small_window2 = imgOrig(1:sizeImage(1)/2,sizeImage(2)/2 +1:end);
small_window3 = imgOrig(sizeImage(1)/2 +1:end,1:sizeImage(2)/2);
small_window4 = imgOrig(sizeImage(1)/2 +1:end,sizeImage(2)/2 +1:end);


dataMatrixSplit(1,:)=small_window1(:);
dataMatrixSplit(2,:)=small_window2(:);
dataMatrixSplit(3,:)=small_window3(:);
dataMatrixSplit(4,:)=small_window4(:);

figure
t = tiledlayout(2,2);
t.TileSpacing = 'compact';
t.Padding = 'compact';
nexttile
imshow(small_window1)
nexttile
imshow(small_window2)
nexttile
imshow(small_window3)
nexttile
imshow(small_window4)
sgtitle("Split image")

%% pca

[coeff, score, ~, ~, explained, mu] = pca(dataMatrixSplit);

threshold = 5; 
cumulativeExplained = cumsum(explained);
nComponents = find(cumulativeExplained >= threshold, 1);

pcaMatrix = score(:, 1:nComponents);
dataMatrixRecons = pcaMatrix * coeff(:, 1:nComponents)' + mu;

%% figures 

figure
t = tiledlayout(2,2);
t.TileSpacing = 'compact';
t.Padding = 'compact';

sizeImage_new=[512,512];

im_slice_1 = uint8(reshape(dataMatrixRecons(1,:), sizeImage_new));
nexttile
imshow(im_slice_1)

im_slice_2 = uint8(reshape(dataMatrixRecons(2,:), sizeImage_new));
nexttile
imshow(im_slice_2)

im_slice_3 = uint8(reshape(dataMatrixRecons(3,:), sizeImage_new));
nexttile
imshow(im_slice_3)

im_slice_4 = uint8(reshape(dataMatrixRecons(4,:), sizeImage_new));
nexttile
imshow(im_slice_4)
sgtitle("Split images after PCA")


%% ica on previuos PCA

[icasig, A_est, W]=fastica(dataMatrixRecons);


% rescaling
minlim=min(icasig');
rangelim=max(icasig')-minlim;
icasig=(icasig-minlim'*ones(1,size(icasig,2)))*255./(rangelim'*ones(1,size(icasig,2)));

sig_size=size(icasig);
if sig_size(1)==4
    %plot ica-output
    figure
    subplot(2,2,1)
    imshow(uint8(reshape(double(icasig(1,:)'),sizeImage_new)))
    subplot(2,2,2)
    imshow(uint8(reshape(double(icasig(2,:)'),sizeImage_new)))
    subplot(2,2,3)
    imshow(uint8(reshape(double(icasig(3,:)'),sizeImage_new)))
    subplot(2,2,4)
    imshow(uint8(reshape(double(icasig(4,:)'),sizeImage_new)))
else
    disp("images too similar! Dimensions are reduced due to singularity of covariance")
    disp("only "+ sig_size(1)+ " images distiguishable")
end


%% Statistische Werte

% %Korrelation Ursprungsbild und PCA
% 
% % Berechnung der Korrelation zwischen den beiden rekonstruierten Bildern
correlation = corr2(imgOrig, imgRecons);

fprintf('Die Korrelation zwischen den beiden optimierten Bildern beträgt: %.4f\n\n', correlation);

