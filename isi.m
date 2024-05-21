clear all, clc;


img = imread('data\images\00000013_005.png');

imshow(img)

img_d = im2double(img);

%Image compression

img_noise_1 = imnoise(img,'gaussian');

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

reconstructed = score * coeff' + repmat(mu, size(coeff,1), 1);

imshow(reconstructed)


% Umrechung in Datenraum mit weniger PCs
toprank = 1;
sum_var = 0;
while sum_var <= 70
    sum_var = sum_var + var_percent(toprank);
    toprank = toprank+1;
end
toprank = toprank-1


approximationRank = score(:,1:toprank) * coeff(:,1:toprank)' + repmat(mu, size(coeff,1), 1);

imshow(approximationRank)

%-------------------------------------------------------------------------------
%PCA with multiple images
%different noises         TODO: man braucht definitiv noch mehr!!!
% resize, damit nicht so viel Arbeitsspeicher gebraucht wird
% ist bisschen doof, weil dann die Bilder sehr verpixelt sind... aber sonst
% rechnet es nicht...
M=100;N=100;
img_re = imresize(img,[M,N]);


% add noise
img_noise_1 = imnoise(img_re,'gaussian');
img_noise_2 = imnoise(img_re,'poisson');
img_noise_3 = imnoise(img_re,'speckle');

imshow(img_re)
imshow(img_noise_1)
imshow(img_noise_2)
imshow(img_noise_3)



% mean picture

mean_img = (img_re + img_noise_1 + img_noise_2 + img_noise_3) / 4;

imshow(mean_img)


% Kompletter Datensatz

img_re_d = im2double(img_re);
img_noise_1_d = im2double(img_noise_1);
img_noise_2_d = im2double(img_noise_2);
img_noise_3_d = im2double(img_noise_3);


% Bilddaten in Matrix speichern (aus Bild MxN wird 1xMN)
n=3; % Anzahl der Bilder
X = zeros(n,(M*N));
X(1,:)=reshape(img_noise_1_d,[1,M*N]); 
X(2,:)=reshape(img_noise_2_d,[1,M*N]); 
X(3,:)=reshape(img_noise_3_d,[1,M*N]); 

% PCA

[coeff_mult, score_mult, latent_mult, tsquared_mult, explained_mult, mu_mult] = pca(X);

% coeff = Spaltenweise Eigenvektoren / Principal components
% score = Principal component scores are the representations of X in the principal component space.
% latent = Eigenwerte/Varianz eines PC (noch nicht in Prozent!)

var_percent_mult = latent_mult ./ sum(latent_mult) .*100;


% ohne "Datenverlust" rekonstruiert
reconstructed_mult = score_mult * coeff_mult' + repmat(mu_mult, n, 1);

% wieder in Bilder aufteilen
im_1=reconstructed_mult(1,:);
im_2=reconstructed_mult(2,:);
im_3=reconstructed_mult(3,:);
reconstructed_1 = reshape(im_1,[M,N]);
reconstructed_2 = reshape(im_2,[M,N]);
reconstructed_3 = reshape(im_3,[M,N]);

imshow(reconstructed_1)
imshow(reconstructed_2)
imshow(reconstructed_3)


% Umrechung in Datenraum mit weniger PCs
toprank_mult = 1;
sum_var_mult = 0;
while sum_var_mult < 70     % hier Prozentzahl anpassen
    sum_var_mult = sum_var_mult + var_percent_mult(toprank_mult);
    toprank_mult = toprank_mult+1;
end
toprank_mult=toprank_mult-1;


approximationRank_mult = score_mult(:,1:toprank_mult) * coeff_mult(:,1:toprank_mult)' + repmat(mu_mult, 3, 1);

%wieder in Bilder aufteilen
im_4=approximationRank_mult(1,:);
im_5=approximationRank_mult(2,:);
im_6=approximationRank_mult(3,:);
approximationRank_mult_1 = reshape(im_4,[M,N]);
approximationRank_mult_2 = reshape(im_5,[M,N]);
approximationRank_mult_3 = reshape(im_6,[M,N]);

imshow(approximationRank_mult_1)
imshow(approximationRank_mult_2)
imshow(approximationRank_mult_3)