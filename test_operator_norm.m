% This file simply test the functionality of operator_norm, to compute
% matrix norm.

clear all;
clc;
close all;

w_tv = 0.2;
w_regularization = 1;
w_cross = [2 3 4; 5 6 7; 8 9 10];

% load('db_chs.mat');
for ch = 1:3
    db_chs(ch).Image = rand(2);
end

% y_test = Kmult_channels(x_test, db_chs, w_tv, w_cross, w_regularization);

% x_test_output = KmultT_channels(y_test, db_chs, w_tv, w_cross, w_regularization);

L = operator_norm(w_regularization, w_tv, w_cross, db_chs, [2 2 3]);