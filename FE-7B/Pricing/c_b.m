function normCall = c_b(y, sigma)
% Normalized price of a European Call option in the Bachelier model.
% INPUTS:
% y     -> vector or float, normalized moneyness
% sigma -> float, volatility parameter

normCall = -y.*normcdf(-y./sigma) + sigma.*normpdf(-y./sigma);

end
