function [sigmaADL,b] = calibrateAddLogistic(marketStrikes, marketCalls, F, yf)
% Calibrate the Additive Logistic Model, by minimizing the L2 distance
% between observed market prices and model prices. The model depennds on
% two parameters, H and sigma. However, the function returns sigmaADL,
% which fits the current ATM volatility term structure, and b, a function
% useful to price exotics derivatives.
% INPUTS:
% marketStrikes -> containers.Map, strikes of the contracts traded in the market
% marketCalls   -> containers.Map, prices of the calls traded in the market
% F             -> vector, forward prices
% yf            -> vector, time to maturities

J = [];

for i=1:8
    L = length(marketStrikes(num2str(i)));
    J = [J, i*ones(1,L)];
end

strikes_tot = cell2mat(values(marketStrikes));
prices_tot = cell2mat(values(marketCalls));
N = length(strikes_tot);

modelPrices = @(s) callSLA(strikes_tot,F(J),s);

f = @(x) 1/N*sum(abs(prices_tot - modelPrices(yf(J).^x(1).*x(2))).^2);

options = optimoptions('fmincon', 'Display', 'off');
parametersSLA=fmincon(f,[0.5,20],[],[],[],[],[],[],[],options);

H = parametersSLA(1);
sigma = parametersSLA(2);

fprintf("ADL parameter H: %d\n", H);
fprintf("ADL parameter sigma: %d\n", sigma);

sigmaADL = sigma.*yf.^(H).*sqrt(2*pi./yf)*log(2);

b=(1-exp(-yf.*(sigma./100).^(1/H))).^H;


end