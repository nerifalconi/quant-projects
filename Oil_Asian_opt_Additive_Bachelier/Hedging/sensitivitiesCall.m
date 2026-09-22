function [vega,sens_kappa,sens_eta,delta] = sensitivitiesCall(kappa, eta, yf, B, F, strike_call_liquid, sigmacall)
% INPUTS:
% kappa -> float, parameter of Additive Bachelier
% eta   -> float, parameter of Additive Bachelier
% yf    -> vector, year fractions
% B     -> float, discount factor
% F     -> float, initial value of the future
% strike_call_liquid     -> float, strike of the contract
% sigmacall-> volatility of Additive Bacheloer  for the moneyness of the
% contract at year TTM
vega = vegaCall(kappa, eta, yf, B, F, strike_call_liquid, sigmacall);
delta = deltaCall(kappa, eta, yf, sigmacall, B, F, strike_call_liquid);
sens_kappa = kappa_Call(kappa, eta, yf, sigmacall, B, F, strike_call_liquid);
sens_eta = eta_Call(kappa, eta, yf, sigmacall, B, F, strike_call_liquid);

end
