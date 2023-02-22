function x = KmultT_channels(y, db_chs, w_tv, w_cross_channels, w_regularization)
% This function compute the computation of transposed matrix K.
x = [];
    for ch = 1:length(y)
        x = cat(3, x, KmultT(y, ch, db_chs, w_tv, w_cross_channels(ch,:), w_regularization));
    end
end

function x = KmultT(y, ch, db_chs, w_tv, w_cross_channels, w_regularization)

%Result
n_ch = length(y);
y = y{ch};
x = zeros(size(y,1), size(y,2));

% derivative filters
dxf=[-1 1];
dyf=[-1;1];

i = 0; % regularization term counter

i = i + 1;
x_tv = - w_tv * div(y(:,:,i:i+1));    
% gather result
x = x + x_tv;
i = i + 1;

i = i + 1; % overall weighting term(???)
xpr = w_regularization * y(:,:,i);
x = x + xpr;

%Cross-Terms for all adjacent channels
for adj_ch = 1:n_ch
    
    %Continue for current channel and zero channels
    if adj_ch == ch || w_cross_channels(adj_ch) < eps()
        continue;
    end
    adjChImg = db_chs(adj_ch).Image; %Curr cross channel
    
    %Compute cross terms
    i = i + 1;
    y(:,:,i) = (w_cross_channels(adj_ch) * 0.5) * y(:,:,i);
    diag_term = imfilter(adjChImg, fliplr(flipud(dxf)), 'conv', 'full');
    diag_term = diag_term(:, 2:end) .* y(:,:,i); 
    conv_term = imfilter(adjChImg.*y(:,:,i), dxf, 'conv', 'full');
    Sxtf = ( conv_term(:,1:(end-1)) - diag_term );
    
    i = i + 1;
    y(:,:,i) = (w_cross_channels(adj_ch) * 0.5) * y(:,:,i);
    diag_term = imfilter(adjChImg, fliplr(flipud(dyf)), 'conv', 'full');
    diag_term = diag_term(2:end, :) .* y(:,:,i); 
    conv_term = imfilter(adjChImg.*y(:,:,i), dyf, 'conv', 'full');
    Sytf = ( conv_term(1:(end-1),:) - diag_term ); 

    %Gather result
    x = x + Sxtf + Sytf;
end
end