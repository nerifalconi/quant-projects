function [C,K,sigma] = calibrateBachelier(strikes, calls, puts, B, F, yf)
% Given the market data on calls and puts, this function calibrates the
% Bachelier model on option prices. Through the use of put-call parity, we
% create a full grid of options. This method is also used to filter away
% all the non-traded options.
% INPUTS:
% strikes -> array, strike prices in the market
% calls   -> array, contract value for every strike
% puts    -> array, contract value for every strike
% B       -> float, discount factor
% F       -> float, forward price
% yf      -> float, year frac

% Normalized Bachelier Call Price
cb = @(y,s) -y.*normcdf(-y./s)+s.*normpdf(-y./s);

% extend the option chain: whenever either the call or the put
% is nan, we use put-call parity to compute the value of the other
mask1 = isnan(calls);
mask2 = isnan(puts);

calls(mask1) = puts(mask1) + B*(F-strikes(mask1));
puts(mask2) = calls(mask2) - B*(strikes(mask2)-F);

% now we have an (almost) complete surface of options. 
% we remove the few ones that remain nan
mask = ~isnan(calls);

C = calls(mask);
K = strikes(mask);

N = length(K);
sigma = zeros(1,N);
x0 = 20;

for i=1:N
    y = @(s) (K(i)-F)/(s*sqrt(yf)); % normalized moneyness
    f = @(s) B*s*sqrt(yf)*cb(y(s),1)-C(i);
    sigma(i) = fzero(f,x0);
end

end