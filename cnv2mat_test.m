clear all;
close all;
clc;
% script to test the cnv2mat object

randn('state', 1)
rand('state', 1)
sx = [8, 8];
sf = [3, 2];
x = randn(sx);
f = randn(sf);

% check all shapes
shapes = {'valid', 'circ', 'same', 'full'};

for j = 2:2
for i = 1:4
  shape = shapes{i};
%   cmode = cmodes{j};
  switch shape
   case {'valid', 'same', 'full'}
    % check against conv2
    tic
    yy = conv2(x, f, shape);
    toc
    F = cnv2mat(f, sx, shape);
    X = cnv2mat(x, sf, shape);
    tic
    y = F * x;
    toc
    diff = norm(y - yy);
    fprintf('''%s'': norm(F*x - conv2(x,f,''%s'')) == %g\n', shape, shape, diff);
    tic
    y = X * f;
    toc
    diff = norm(y-yy);
    fprintf('''%s'': norm(X*f - conv2(x,f,''%s'')) == %g\n', shape, shape, diff);
  end
  % check the transpose of F and X
%   diff = norm(full(F)' - full(F'));
%   fprintf('''%s'': norm(full(F)'' - full(F'')) == %g\n', shape, diff);
%   diff = norm(full(X)' - full(X'));
%   fprintf('''%s'': norm(full(X)'' - full(X'')) == %g\n', shape, diff);
end
end