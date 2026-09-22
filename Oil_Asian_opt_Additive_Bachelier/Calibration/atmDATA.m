function callATM = atmDATA(strikes, calls, puts, B, F)
% Given the forward price, we can interpolate on the market data to recover
% the price of the ATM-fwd call option. 
% INPUTS:
% strikes -> array, strikes quoted in the market
% calls   -> array, call prices for every strike (even nan)
% puts    -> array, put prices for every strike (even nan)
% B       -> float, discount factor
% F       -> float, forward price

% Before interpolating, we generate a full grid of options using put-call
% parity. Whenever the call is nan, we look at the corresponding put and
% compute the non-arbitrage price.
maskCall = isnan(calls);
calls(maskCall) = puts(maskCall) + B*(F-strikes(maskCall));

% If also the corresponding put is nan, we just drop the point altogether
maskNan = ~isnan(calls);
K = strikes(maskNan);
calls = calls(maskNan);

% Spline interpolation
callATM = interp1(K, calls, F, 'spline');

end