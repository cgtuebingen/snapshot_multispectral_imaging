function y = mtimes(obj, x)

if obj.tp
  % transposed
  switch obj.shape
    case 'same'
      gx = x{1};
      gy = x{2};
      switch obj.type
        case ''
          y = - gx - gy;
          y(:,2:end) = y(:,2:end) + gx(:,1:end-1);
          y(2:end,:) = y(2:end,:) + gy(1:end-1,:);
          y = y / sqrt(2.);
        case 'ext'
          error('Not implemented yet');
      end
    case 'valid'
      error('Not implemented yet');
  end
  
else
  switch obj.shape
    case 'same'
      switch obj.type 
        case ''
          xp = padn(x, size(x)+1);  
          gx = (xp(1:end-1,2:end)-x)/sqrt(2.);
          gy = (xp(2:end,1:end-1)-x)/sqrt(2.);
        case 'ext'
          gp = [0.037659 0.249153 0.426375 0.249153 0.037659]';
          gd = [-0.109604 -0.276691 0.000000 0.276691 0.109604]'; 
          %gp = [0.229879 0.540242 0.229879]';
          %gd = [0.425287 0.000000 -0.425287]';
          fx = gp*gd';
          fy = gd*gp';
          
          gx = imfilter(x, fx, 'conv');
          gy = imfilter(x, fy, 'conv');
      end
    case 'valid'
      switch obj.type 
        case ''
          gx = (x(:,2:end)-x(:,1:end-1))/sqrt(2.);
          gy = (x(2:end,:)-x(1:end-1,:))/sqrt(2.);
        case 'ext'
          error('Not implemented yet');
      end
  end
  y = {gx, gy};
  
end
return
