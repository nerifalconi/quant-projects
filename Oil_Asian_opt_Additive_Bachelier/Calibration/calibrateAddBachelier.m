function [kappa,eta,sigmat,MSE] = calibrateAddBachelier(marketNormMoneyness, marketNormCalls, sigmaATM)
% Calibrate the Additive Bachelier Model, minimzing the distance between
% observed market prices and model prices, computed through FFT.
% In particular, for each normalized moneyness traded in the market, we try
% to matched the normalized call prices.
% INPUTS:
% marketNormMoneyness -> containers.Map, for each maturity (container key) normalized moneyness
% marketNormCalls     -> containers.Map, for each maturity (container key) normalized call prices
% sigmaATM            -> vector, volatilities At The Money

% This function is designed to work for both yearly calibration or total
% calibration. The latter takes into consideration all the traded for every
% time maturity. To distinuish between the two scenarios, we actually check
% the type of marketNormMoneyness (and consequently marketNormCalls, since they must be equal).
% If it's a dictionary, than the calibration is global. Instead, if it's a
% vector, the calibration will be done for just the current year.
if isa(marketNormMoneyness,'containers.Map')
    norm_moneyness = cell2mat(values(marketNormMoneyness));
    norm_prices = cell2mat(values(marketNormCalls));
elseif isvector(marketNormMoneyness)
    norm_moneyness = marketNormMoneyness;
    norm_prices = marketNormCalls;
end

modelprice=@(k,eta) callFFT(norm_moneyness,k,eta);

% Objective function
dist=@(rho) sum(abs(modelprice(rho(1),rho(2))-norm_prices).^2);
%minimization
initial_guess = [1;0.2]; 

% Constrained optimization
options = optimoptions('fmincon', 'Display', 'off');
parameters = fmincon(dist,initial_guess,[],[],[],[],[],[],[],options);

%Getting the Model Parameters
kappa = parameters(1);
eta = parameters(2);
I0 = I0funct(0,kappa,eta);
sigmat = sigmaATM/I0;

MSE = sum(abs(modelprice(kappa,eta)-norm_prices).^2);

end