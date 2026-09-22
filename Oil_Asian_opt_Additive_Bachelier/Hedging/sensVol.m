function sens = sensVol(kappa,eta,B,yf,F,sigmaATM,priceAB,K)
% Sensitivity of the Asian Digital option to an upward shift in volatility.
% INPUTS:
% kappa -> float, parameter of Additive Bachelier
% eta   -> float, parameter of Additive Bachelier
% B     -> float, discount factor
% yf    -> vector, year fractions
% F     -> float, initial value of the future
% sigmaATM -> vector, sigma at the money term structure
% priceAB -> float, original price of the contract
% K     -> float, strike of the contrac

bp = 1e-1;

sigmaATMShifted = sigmaATM+bp;

I0 = I0funct(0, kappa, eta);

sens = (exoticADB(kappa,eta,yf,F,sigmaATMShifted/I0,K,B)-priceAB)/bp;

end