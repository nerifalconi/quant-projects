function sens = sensEta(kappa,eta,B,yf,F,sigmaATM,priceAB,K)
% Sensitivity of the Asian Digital option to an upward shift in eta.
% INPUTS:
% kappa -> float, parameter of Additive Bachelier
% eta   -> float, parameter of Additive Bachelier
% B     -> float, discount factor
% yf    -> vector, year fractions
% F     -> float, initial value of the future
% sigmaATM -> vector, sigma at the money term structure
% priceAB -> float, original price of the contract
% K     -> floa, strike of the contrac


bp = 1e-2;
eta = eta + bp;

I0 = I0funct(0, kappa, eta);

sens = (exoticADB(kappa,eta,yf,F,sigmaATM/I0,K,B)-priceAB)/bp;

end