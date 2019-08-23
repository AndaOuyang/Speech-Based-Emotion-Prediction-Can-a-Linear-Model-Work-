function ccc = ccc_calculation(x, y)

ccc = 2*corr(x,y)*std(x)*std(y)/(var(x)+var(y)+(mean(x)-mean(y)).^2);

