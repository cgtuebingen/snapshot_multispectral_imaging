function y = mtimes(obj, x)

switch obj.pattern
case 'rggb'
if obj.tp
    y = zeros(size(x,1), size(x,2), obj.ncolors);       % RGB
%     for i = 1:obj.ncolors
%       if obj.cfa_weights(2,i) > 0
%         y(2:2:end,1:2:end,i) = y(2:2:end,1:2:end,i) + x(2:2:end,1:2:end) / obj.cfa_weights(2,i);
%         y(1:2:end,2:2:end,i) = y(1:2:end,2:2:end,i) + x(1:2:end,2:2:end) / obj.cfa_weights(2,i);
%       end
%       if obj.cfa_weights(1,i) > 0
%         y(1:2:end,1:2:end,i) = y(1:2:end,1:2:end,i) + x(1:2:end,1:2:end) / obj.cfa_weights(1,i);
%       end
%       if obj.cfa_weights(3,i) > 0
%         y(2:2:end,2:2:end,i) = y(2:2:end,2:2:end,i) + x(2:2:end,2:2:end) / obj.cfa_weights(3,i);     
%       end 
%     end    
    for i = 1:obj.ncolors
      if obj.cfa_weights(2,i) > 0
        y(2:2:end,1:2:end) = y(2:2:end,1:2:end, i) + x(2:2:end,1:2:end) * obj.cfa_weights(2,i);        
        y(1:2:end,2:2:end) = y(1:2:end,2:2:end, i) + x(1:2:end,2:2:end) * obj.cfa_weights(2,i);
      end
      if obj.cfa_weights(1,i) > 0     
        y(1:2:end,1:2:end) = y(1:2:end,1:2:end, i) + x(1:2:end,1:2:end) * obj.cfa_weights(1,i);
      end
      if obj.cfa_weights(3,i) > 0            
        y(2:2:end,2:2:end) = y(2:2:end,2:2:end, i) + x(2:2:end,2:2:end) * obj.cfa_weights(3,i);       
      end
    end
else
    y = zeros(size(x,1), size(x,1));                    % RAW
    for i = 1:obj.ncolors
      if obj.cfa_weights(2,i) > 0
        y(2:2:end,1:2:end) = y(2:2:end,1:2:end) + x(2:2:end,1:2:end,i) * obj.cfa_weights(2,i);        
        y(1:2:end,2:2:end) = y(1:2:end,2:2:end) + x(1:2:end,2:2:end,i) * obj.cfa_weights(2,i);
      end
      if obj.cfa_weights(1,i) > 0     
        y(1:2:end,1:2:end) = y(1:2:end,1:2:end) + x(1:2:end,1:2:end,i) * obj.cfa_weights(1,i);
      end
      if obj.cfa_weights(3,i) > 0            
        y(2:2:end,2:2:end) = y(2:2:end,2:2:end) + x(2:2:end,2:2:end,i) * obj.cfa_weights(3,i);       
      end
    end
end
otherwise 
 error('[bayer2mat] Bayer pattern not defined')
end
return
