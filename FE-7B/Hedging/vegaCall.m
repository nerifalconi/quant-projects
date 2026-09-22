function vega = vegaCall(kappa, eta, ttm, B, F0, strike, sigmaATM)
% Computing the Vega of a Call option under the Additive Bachelier model
% using a numerical derivative method. The approach consists in bumping the
% ATM volatility (sigma), computing the normalized option price with the 
% bumped sigma, and then denormalizing the result using the same bumped sigma.
% INPUTS:
% kappa -> float, Additive Bachelier Model vol of vol parameter
% eta   -> float, Additive Bachelier Model skewness paratemr
% ttm   -> float, time to maturity (year frac)
% B     -> float, discount factor
% F0    -> float, initial value of the forward
% K     -> float, strike of the option
% sigmaATM-> float, volatility ATM for the TTM

bp = 1e-1;

x = (strike-F0)./(sigmaATM*sqrt(ttm)*B);
normPrice = callFFT(x,kappa,eta);

x_up = (strike-F0)./((sigmaATM+bp)*sqrt(ttm)*B);
normPrice_up = callFFT(x_up,kappa,eta);

price = sigmaATM.*sqrt(ttm)*B.*normPrice;
price_up = (sigmaATM+bp)*sqrt(ttm)*B*normPrice_up;

vega = (price_up-price)/bp;

end

