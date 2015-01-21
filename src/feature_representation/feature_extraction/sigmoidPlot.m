function sigmoidPlot() 
    figure;
    
    x =[10:0.1:30];
    y = sigmoidFunction(x);
    
    plot(x, y, 'g');
    
end

