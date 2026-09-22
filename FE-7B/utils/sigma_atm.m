function sigmaATM = sigma_atm(callATM,yf,B,plotflag)
% sigma at the money parameters of the Bachelier model, for more detail
% look at the paper by Massaria: "The Additive Bachelier model 
% with an application to the oil option market in the Covid period"
% INPUTS:
% callATM -> array, atm calls previously computed with interpolation
% yf -> array, yearfrac between today and expiry
% B  -> array, discount factors
% plotflag -> bool, plotting flag

sigmaATM = sqrt(2*pi./yf).*(callATM./B);

if plotflag
    figure;
    plot(yf, sigmaATM, "-*", 'LineWidth',1.5, 'Color', 'Red');
    grid on; title("ATM Volatilies - Term Structure");
    xticks(yf); xlabel("Years");
end

end