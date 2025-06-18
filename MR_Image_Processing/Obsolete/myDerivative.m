%% KC: return derivative of x with respect to y using gradient function
% Use of bulit-in function diff will lose the no. of elements 
function res = myDerivative(x,y)
    res = gradient(x)./gradient(y);
end