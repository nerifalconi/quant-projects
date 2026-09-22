function [vega,sens_kappa,sens_eta,delta] = sensitivitiesEx(kappa,eta,B,yf,F,sigmaATM,priceAD,sigmat)
% Risk factors of the Exotic product, with respect to changes in volality,
% vol of vol, skewness and underlying.
% INPUTS:
% kappa -> float, vol of vol. Calibrated from AddBachelier
% eta   -> float, skewness. Calibrated from AddBachelier
% B     -> float, discount factor
% yf    -> vector, year frac of reset Dates
% sigmaAMT -> vector, sigma term structure
% priceAD -> float, original price of asian digital
% sigmat  -> vector, sigmat term structure

vega = sensVol(kappa,eta,B,yf,F,sigmaATM,priceAD,F);
sens_kappa = sensKappa(kappa,eta,B,yf,F,sigmaATM,priceAD,F);
sens_eta = sensEta(kappa,eta,B,yf,F,sigmaATM,priceAD,F);
delta=(exoticADB(kappa,eta,yf,F+1e-1,sigmat,F,B)-priceAD)/1e-1;

end
