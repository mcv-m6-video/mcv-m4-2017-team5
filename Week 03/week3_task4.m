clear all
close all
clc
addpath(genpath('.'))

%Directory where the masks of the different sets are placed
% sequence = 'highway/';
sequence = 'fall/';
% sequence = 'traffic/';



directory_write = strcat('../Results/week3/', sequence);
directory_write_grid = '../Results/week3/';
alpha = 0.1510;
rho = 0;
percentage = 0.5;

param  = compute_parameters_w3(sequence, directory_write, alpha, rho, percentage);


%%

