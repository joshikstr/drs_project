% PCA wird auf ein Bild angewandt
% durch Reduktion der Komponenten bei der Ruecktransformation, werden 'unwichtige' Daten weggelassen
% -> Bild kann auch bei einem gewissen Maß an Datenreduktion noch gut dargestellt werden
% -> ab einem bestimmten Punkt gibt es Informationsverlust

clear all, clc;
close all;


addpath data\
addpath functions\

imds = imageDatastore("data\images\");

img = readimage(imds,1);


figure
imshow(img)

img_d = im2double(img);

%Image compression

img_noise_1 = imnoise(img,'gaussian');

figure
imshow(img_noise_1)

img_noise_1_d = im2double(img_noise_1);


%-------------------------------------------------------------------------------
%PCA
%pca (mit nur einem Bild): image compression
%-------------------------------------------------------------------------------
[coeff, score, latent, tsquared, explained, mu] = pca(img_noise_1_d);

% coeff = Spaltenweise Eigenvektoren / Principal components
% score = Principal component scores are the representations of X in the principal component space.
% latent = Eigenwerte/Varianz eines PC (noch nicht in Prozent!)

var_percent = latent ./ sum(latent) .*100;


% Umrechnung pca raum wieder in Datenraum
% reconstruct data

reconstructed = score * coeff' + mu;

figure
imshow(reconstructed)

% reconstruction with less PCs
threshold=70;
cumulativeExplained = cumsum(explained);
nComponents = find(cumulativeExplained >= threshold, 1);

approximationRank = score(:,1:nComponents) * coeff(:,1:nComponents)' + mu;
figure
imshow(approximationRank)
title({num2str(threshold) + " percent of Variance; "; num2str(nComponents) + " Principal Components"})


figure
t = tiledlayout(2,5);
t.TileSpacing = 'compact';
t.Padding = 'compact';
n=1;
for threshold = 10:10:90
    % Umrechung in Datenraum mit weniger PCs
    cumulativeExplained = cumsum(explained);
    nComponents = find(cumulativeExplained >= threshold, 1);
    
    
    approximationRank = score(:,1:nComponents) * coeff(:,1:nComponents)' + mu;
    
    nexttile
    imshow(approximationRank)
    title({num2str(threshold) + " percent of Variance; "; num2str(nComponents) + " Principal Components"})
    n=n+1;
end

nexttile
imshow(reconstructed)
title( {"100 percent of Variance; " ; num2str(size(coeff,2)) + " Principal Components"})
sgtitle('Reconstruction with different levels of data compression')
