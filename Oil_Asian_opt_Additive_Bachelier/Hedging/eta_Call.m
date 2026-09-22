function sens = eta_Call(kappa, eta, ttm, sigmaATM, B, F0, strike)
% Computing the delta of a Call option under the Additive Bachelier model
% using a numerical derivative method. The approach consists in bumping the
% eta, computing the normalized option price with the 
% bumped eta, and then denormalizing the result.
% INPUTS:
% kappa -> float, Additive Bachelier Model vol of vol parameter
% eta   -> float, Additive Bachelier Model skewness paratemr
% ttm   -> float, time to maturity (year frac)
% sigmaATM-> float, volatility ATM for the TTM
% B     -> float, discount factor
% F0    -> float, initial value of the forward
% K     -> float, strike of the option
bp = 1e-2;

x = (strike-F0)./(sigmaATM*sqrt(ttm)*B);
normPrice = callFFT(x,kappa,eta);
normPrice_up = callFFT(x,kappa,eta+bp);

price = sigmaATM.*sqrt(ttm)*B.*normPrice;
price_up = sigmaATM*sqrt(ttm)*B*normPrice_up;

sens = (price_up-price)/bp;

end