function [ result ] = observationMat( x, channels, flag  )
    %Do the image formation
    sizeX = size(x);
    result = zeros( sizeX );
    [red_mask, green_mask, blue_mask] = generate_bayer_mask(size(x(:, :, 1)), 'rggb');
    cfa_mask = cat(3, red_mask, green_mask, blue_mask);
    
    for ch = 1:size(x,3)
        
        %Iterate over the channels
        if flag > 0      

            % A
            result(:,:,ch) = cfa_mask(:,:,ch) .* imfilter(x(:,:,ch), channels(ch).K, 'same', 'replicate');
        elseif flag < 0 

            % A'
            if ch ~= 2
                result(:,:,ch) = imfilter( cfa_mask(:,:,ch) .* x(:,:,ch) , fliplr(flipud(channels(ch).K)), 'same', 'conv', 'replicate');
            else
                result(:,:,ch) = imfilter( cfa_mask(:,:,ch) .* x(:,:,ch) , fliplr(flipud(channels(ch).K)), 'same', 'conv', 'replicate')/2;
            end
        else

            % A'A
            Ax = cfa_mask(:,:,ch) .* imfilter(x(:,:,ch), channels(ch).K, 'same', 'replicate');
%             result(:,:,ch) = imfilter(Ax .* x(:,:,ch), fliplr(flipud(channels(ch).K)), 'same', 'conv', 'replicate');
            if ch ~= 2
                result(:,:,ch) = imfilter( Ax .* x(:,:,ch) , fliplr(flipud(channels(ch).K)), 'same', 'conv', 'replicate');
            else
                result(:,:,ch) = imfilter( Ax .* x(:,:,ch) , fliplr(flipud(channels(ch).K)), 'same', 'conv', 'replicate')/2;
            end
        end  
        
    end
    
return;