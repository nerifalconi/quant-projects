function delta = deltaCall(kappa, eta, ttm, sigmaATM, B, F0, strike)
% Computing the delta of a Call option under the Additive Bachelier model
% using a numerical derivative method. The approach consists in bumping the
% Forward, computing the normalized option price with the 
% bumped forward, and then denormalizing the result using the same bumped forward.
% INPUTS:
% kappa -> float, Additive Bachelier Model vol of vol parameter
% eta   -> float, Additive Bachelier Model skewness paratemr
% ttm   -> float, time to maturity (year frac)
% sigmaATM-> float, volatility ATM for the TTM
% B     -> float, discount factor
% F0    -> float, initial value of the forward
% K     -> float, strike of the option
bp = 1e-1;

x = (strike-F0)./(sigmaATM*sqrt(ttm)*B);
normPrice = callFFT(x,kappa,eta);

x_up = (strike-F0-bp)./(sigmaATM*sqrt(ttm)*B);
normPrice_up = callFFT(x_up,kappa,eta);

price = sigmaATM.*sqrt(ttm)*B.*normPrice;
price_up = sigmaATM*sqrt(ttm)*B*normPrice_up;

delta = (price_up-price)/bp;

end