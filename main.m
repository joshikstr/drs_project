%% init
clear 
close all
clc

addpath data\
addpath functions\

imds = imageDatastore("data\images\");

%% bsp first image

img_1 = readimage(imds,1);
imshow(img_1)

img_1_noise = imnoise(img_1,'gaussian');
figure
imshow(img_1_noise)

%% pca

coeff = pca(double(img_1_noise));
figure
idisp(coeff)

coeff_ref = pca(double(img_1));
figure
idisp(coeff_ref)