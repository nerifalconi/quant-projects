function [moneyness,impvol] = impvolAddBachelier(kappa, eta)
% Calculating the normalized moneyness and implied volatility.
% INPUTS:
% kappa -> float, parameter of Additive Bachelier
% eta   -> float, parameter of Additive Bachelier
moneyness = -20:2:20;
impvol = zeros(1,length(moneyness));

initialCond = 2;

for k=1:length(moneyness)
    f = @(vol) c_b(moneyness(k), vol) - callFFT(moneyness(k), kappa, eta);
    impvol(k) = fzero(f,initialCond);
    initialCond = impvol(k);
end

end