function [price] = bachelier(x, t, sigma, B)
% Call price under the Bachelier Model (Bachelier 1901)
% The model provides an analytical formula for a european call option,
% based on the gaussianity assumption of the underlying.
% INPUTS:
% x -> vector or float, moneyness
% t -> float, time to maturity (year frac)
% sigma -> volatility term structure, function handle

price = B.*sigma(t).*sqrt(t).*c_b(x./(sigma(t).*sqrt(t)),1);

end