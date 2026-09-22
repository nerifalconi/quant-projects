function [price,F_AB,CI_fwd,CI_price] = exoticADB(kappa,eta,yf,F0,sigmat,K,B)
% Price of exotic path dependent option under the Additive Bachelier Model, priced
% with a Monte Carlo simulation. Following the algorithm described in
% Azzone, Baviera "A fast Monte Carlo scheme for additive processes and
% option pricing", we've developed a routine to sample points from the
% Additive Bachelier Model distribution, without having an explicit
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
% kappa -> float, Additive Bachelier Model vol of vol parameter
% eta   -> float, Additive Bachelier Model skewness paratemr
% yf    -> vector, time to maturity (year frac)
% sigmat -> vector, volatility term structure (sigmaATM normalized by I0)
% F0    -> float, initial value of the forward
% K     -> float, strike of the option
% B     -> float, discount factor

% The function does not only return the price and its associated confidence
% interval CI_price, but it also returns all the paths of the simulated
% forward F_AB and a confidence interval on their mean.

% MC parameters: number of simulations and seed setting
Nsim = 10000000;
rng(42);

F = zeros(Nsim,length(yf)+1);
F(:,1) = F0;
XX=-40:0.1:40;
for i=1:length(yf)
    % The CDF is estimated in a separate function, called cdfFFT. For more
    % details on how that work, see the method implementation.
    
    % Since the model is additive, the characteristic function of the
    % increment f(t) - f(s) is the ratio of the two characteristic functions
    % phi(t) and phi(s). If i == 1, we are at our first instant, so there's
    % no increment whatsover.
    if i==1
       caratt=charFunction(sigmat(i),yf(i),kappa,eta);
       P=cdfFFT([yf(i),0],caratt,XX);
    else
       caratt1=charFunction(sigmat(i),yf(i),kappa,eta);
       caratt2=charFunction(sigmat(i-1),yf(i-1),kappa,eta);
       caratt=@(u) caratt1(u)./caratt2(u);
       P=cdfFFT([yf(i),yf(i-1)],caratt,XX);
    end
    
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
    
    if numel(P) ~= numel(unique(P))
        disp("Warning! Duplicates are present in P");
        [P, idx] = unique(P, 'stable');
        XX = XX(idx);
    end

    X = interp1(P,XX,U);
    
    if any(isnan(X))
        % There shouldn't be any, because of the fix explained above
        disp("found nan")
    end
    
    F(:,i+1)=F(:,i)+X';
end

% ASIAN DIGITAL payoff: we compute the mean of forward throughout its
% path. Whenever this mean is bigger than the strike price K, the contract
% pays one dollar. The average payoff is then discounted back with B.

Media = mean(F(:,2:end),2);
payoff = (Media>K);
price = B*mean(payoff);

F_AB = mean(F(:,2:end),1);

[~,~,CI_fwd] = normfit(F_AB);
[~,~,CI_price] = normfit(payoff);

end
