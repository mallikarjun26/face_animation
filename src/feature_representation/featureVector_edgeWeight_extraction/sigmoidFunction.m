function [y] = sigmoidFunction(x)
    y = [];
    denominator =  (1 + exp(  -(x-26)/2 ))  ;
    for i=1:size(x,2)
        tempValue = 1000 * ( 1/denominator(1,i) );
        y = [y; tempValue];
    end
end