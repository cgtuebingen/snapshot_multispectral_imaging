clear all;
close all;
clc;

%% Setting breakpoints

dbclear all;
dbstop if error
dbstop in demo_deblur at 71
dbstop in pd at 32
demo_deblur;