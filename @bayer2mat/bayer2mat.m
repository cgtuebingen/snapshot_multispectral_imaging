function obj = bayer2mat(sx, pattern, cfa_weights)
%BAYER2MAT creates a matrix object for Bayering 
% Michael Hirsch | March 2014

if ~exist('pattern', 'var'); pattern = 'grbg'; end
if ~exist('cfa_weights', 'var'); cfa_weights = eye(3); end

ncolors = size(cfa_weights,2);

% store all stuff in the structure
obj.s = [prod(sx) prod(sx)*ncolors];
obj.pattern = pattern;
obj.cfa_weights = cfa_weights;
obj.ncolors = ncolors;
obj.tp = false;    % is the resulting matrix transposed?
obj = class(obj, 'bayer2mat');
