function obj = cnv2mat(f, sx, shape)
%CNV2MAT creates a matrix object for 2d convolutions.
%
% Inputs:
%   f        the left-hand-side of the convolution
%   sx       the size of the right-hand-side of the convolution
%   shape    one of 'valid', 'circ', see CONV2
%
% Usage:
%   F = cnv2mat(f, sx, 'valid');
%   y = F*x;    % same as y = cnv2(f, x, 'valid');
%
% SH * 9 NOV 2009
% Mohammad * 3 DEC 2009 (added cmode feature)
% SH * 10 NOV 2011  (removed cmode feature)

sf = size(f);    % size of the psf, not of the matrix
if any(sf < sx) && any(sf > sx)
  error('[%s.m] size missmatch', mfilename);
end
sz = max(sx, sf);    % the bigger one
sw = min(sx, sf);    % the smaller one
switch shape
 case 'valid'
  sy = sz - sw + 1;
 case 'circ'
  sy = sz;
 case 'same'
  sy = sz;
  sz = sx + sf - 1;
 case 'full'
  sz = sx + sf - 1;
  sy = sz;
 otherwise
  error('unknown shape');
end

% precompute some fft already
z = fftn(f, sz);

% calculate its size
s = [prod(sy), prod(sx)];

% store all stuff in the structure
obj.s     = s;        % precomputed size
obj.shape = shape;    % shape of the convolution
obj.f     = f;        % PSF
obj.z     = z;        % precomputed FFT
obj.sx    = sx;       % input dimension
obj.sy    = sy;       % output dimension
obj.sf    = sf;       % size of the PSF
obj.sz    = sz;       % size of the FFT
obj.sw    = sw;       % size of the PSF
obj.tp    = false;    % is the resulting matrix transposed?
obj = class(obj, 'cnv2mat');
