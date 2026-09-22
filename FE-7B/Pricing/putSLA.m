function price = putSLA(K,S0,s)
% Price of a European Put Option under the real-value Additive Logistic
% Framework, a logistic analogue of the Bachelier Model.
% The ADL price depedens on s(t), a positive value function calibrated to
% market data. The particular shape of s(t) depends on the chosen model
% inside of the the additive logistic family.
% INPUTS:
% K: float, strike
% S0: float, value of the underlying
% s: vector or float, s parameter of the ADL

price = s.*log(1+exp((K-S0)./s));
end