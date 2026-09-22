function [price,F,IC_price,IC_fwd] = exoticADL(b,B,yf,F0)
% Price of exotic path dependent option under the Additive Logistic Framework,
% priced with a Monte Carlo simulation. Following the algorithm described in
% Azzone, Baviera "A fast Monte Carlo scheme for additive processes and
% option pricing", we've developed a routine to sample points from the
% Additive Logistic Framework distribution, without having an explicit
% analytical expression for it. The algorithm is based on the numerical
% reconstruction of the Cumulative Distribution Function (CDF), through the
% use of Fast Fourier Transform (FFT). Once the CDF has been estimated, we
% generate samples from a uniform distribution U and invert the relation
% P(X) = U. Lastly, we compute the payoff function: the option is binary
% (digital); it pays one if the mean of the underlying over the simulation
% period is above the strike. Since it is combining these two features:
% binary payout and mean of the underlying, we will often refer to this
% contract as ASIAN DIGITAL OPTION.
% INPUTS:
% b  -> vector, parameter of the Additive Logistic Framework
% B  -> float, discount factor
% yf -> vector, time to maturities (year frac of reset dates)
% F0 -> float, initial value of the underlying
% K  -> float, strike price
% The function does not only return the price and its associated confidence
% interval CI_price, but it also returns all the paths of the simulated
% forward F_AB and a confidence interval on their mean.

% WARNING! This function is slow. The characterstic function of the
% Additive Logistic Framework requires the use of Beta function, valued of
% a complex argument. However, MATLAB built-in implementation of the beta
% function does not support complex argument, so we had to write our own,
% using a numerical integration scheme. The code can not be vectorized and
% henceforth results in being slow and inefficient. We found no possible
% alternative to this custom solution. The MATLAB doc suggest declearing
% arguments as symbolic to use the built-in Beta function. We found this
% approach to be even slower than our own.

% MC parameters: number of simulations and seed setting
K=F0;
Nsim = 10000;

rng(42);

F = zeros(Nsim,length(yf)+1);
F(:,1) = F0;
XX=-1:0.01:1;
for i=1:length(yf)
    % The CDF is estimated in a separate function, called cdfFFT. For more
    % details on how that work, see the method implementation.
    
    % Since the model is additive, the characteristic function of the
    % increment f(t) - f(s) is the ratio of the two characteristic functions
    % phi(t) and phi(s). If i == 1, we are at our first instant, so there's
    % no increment whatsover.
    fprintf("Processing time to maturity: %d\n",i);
    
    if i==1
       caratt = charFunctionADL(b(i));
       P = cdfFFT([yf(i),0],caratt,XX);
    else
       caratt1 = charFunctionADL(b(i));
       caratt2 = charFunctionADL(b(i-1));
       caratt = @(u) caratt1(u)./caratt2(u);
       P = cdfFFT([yf(i),yf(i-1)],caratt,XX);
       
    end

    idx_gt0 = find(P> 0, 1);
    if max(P) < 1
        idx_gt1 = length(P);
    else
        idx_gt1 = find(P>1, 1);
    end
    P = P(idx_gt0:idx_gt1-1);
    XX = XX(idx_gt0:idx_gt1-1);
    
    % To check the CDF has been generated correctly, we can actually
    % visualize it. Results are pretty nice.
    % We suggest to keep this part of the code commented.
    % if i < 4
    %     plot(XX,P,'LineWidth',1.2);
    %     hold on; grid on;
    % end
    % if i == 3
    %     legend(["$P_1(x)$","$P_2(x)$","$P_3(x)$"])
    % end
    
    % Sampling from uniform distribution and inverting the CDF relation
    U = rand(1, Nsim);
    
    % In some rare case, the sampled point U is exactly equal to 1 or 0. If
    % that happens, since P will never reach the two bounds because of
    % numerical limitations, we code will start throwing NaNs which will
    % ultimately results in some form of error. To avoid this situation, we
    % cap the maximum and the minimum sampled valued to the actual max and
    % min obsevered in the CDF P.

    maskMax = U > max(P);
    maskMin = U < min(P);
    
    U(maskMax) = max(P);
    U(maskMin) = min(P);
     
    X = interp1(P,XX,U);
   
    if any(isnan(X))
           % There shouldn't be any, because of the fix explained above
           disp("found nan")
    end
    
    F(:,i+1)=F(:,i)+X';
end

Media = mean(F(:,2:end),2);
payoff = (Media>K)*B;
price = mean(payoff);

[~,~,IC_fwd] = normfit(F);
F=mean(F(:,2:end),1);
[~,~,IC_price] = normfit(price);

end