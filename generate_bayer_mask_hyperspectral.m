% Function to generate sampling mask for hyperspectral imaging

function mask = generate_bayer_mask_hyperspectral( sz, pattern, cfa_calibration_weights )
% generate hyperspectral color mask for bayer

n_colors = size(cfa_calibration_weights,2);

mask = cell(n_colors,1);

switch pattern
  case 'rggb'
    for i = 1:n_colors
      mask{i} = struct();
      mask{i}.r_mask = zeros(sz);
      mask{i}.g_mask = zeros(sz);
      mask{i}.b_mask = zeros(sz);
      
      % red
      mask{i}.r_mask(1:2:end, 1:2:end) = cfa_calibration_weights(1,i);

      % green
      mask{i}.g_mask(1:2:end, 2:2:end) = cfa_calibration_weights(2,i);
      mask{i}.g_mask(2:2:end, 1:2:end) = cfa_calibration_weights(2,i);
      
      % blue
      mask{i}.b_mask(2:2:end, 2:2:end) = cfa_calibration_weights(3,i);
    end
  
case 'grbg'
    % green
    g_mask(1:2:end, 1:2:end) = 1;
    g_mask(2:2:end, 2:2:end) = 1;

    % red
    r_mask(1:2:end, 2:2:end) = 1;

    % blue
    b_mask(2:2:end, 1:2:end) = 1;
end
return

