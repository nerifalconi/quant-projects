function [sigmacall,sigmaput] = sigma_mkt(moneynessRed, impvol, sigmaATM, yf, F)

% we hedge with call and put with strike 42 and 40

moneynessCall = 42 - F;
moneynessPut = 40 - F;

I = impvol * sigmaATM;
x = moneynessRed * sqrt(yf) * sigmaATM;
sigmacall = spline(x, I, moneynessCall);
sigmaput = spline(x, I, moneynessPut);

end
