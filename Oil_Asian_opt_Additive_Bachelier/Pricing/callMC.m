function [price,CI] = callMC(kappa,eta,yf,sigmat,F0,K,B)
% Price of European Call Option under the Additive Bachelier Model, priced
% with a Monte Carlo simulation. Following the algorithm described in
% Azzone, Baviera "A fast Monte Carlo scheme for additive processes and
% option pricing", we've developed a routine to sample points from the
% Additive Bachelier Model distribution, without having an explicit
% analytical expression for it. The algorithm is based on the numerical
% reconstruction of the Cumulative Distribution Function (CDF), through the
% use of Fast Fourier Transform (FFT). Once the CDF has been estimated, we
% generate samples from a uniform distribution U and invert the relation
% P(X) = U. Lastly, we compute the payoff function of a European call and
% discount back with the boostrapped discount factor.
% INPUTS:
% kappa -> float, Additive Bachelier Model vol of vol parameter
% eta   -> float, Additive Bachelier Model skewness paratemr
% yf    -> vector, time to maturity (year frac)
% sigmat -> vector, volatility term structure (sigmaATM normalized by I0)
% F0    -> float, initial value of the forward
% K     -> float, strike of the option
% B     -> float, discount factor

% MC parameters: number of simulations and seed setting
Nsim = 10000000;
rng(42);

F = zeros(Nsim,length(yf)+1);
F(:,1) = F0;
XX=-200:0.1:200;

% We simulate the whole path of the contract, so that this very some code
% can be re-used when pricing exotic path depend products. For a more
% general implementation of this monte carlo framework, see our Python
% port. Here we are somewhat constrained by MATLAB limited support for
% abstraction and polymorphism.

for i=1:length(yf)
    % The CDF is estimated in a separate function, called cdfFFT. For more
    % details on how that work, see the method implementation.
    
    % Since the model is additive, the characteristic function of the
    % increment f(t) - f(s) is the ratio of the two characteristic functions
    % phi(t) and phi(s). If i == 1, we are at our first instant, so there's
    % no increment whatsover.
    if i==1
       caratt = charFunction(sigmat(i),yf(i),kappa,eta);
       P = cdfFFT([yf(i),0],caratt,XX);
    else
       caratt1 = charFunction(sigmat(i),yf(i),kappa,eta);
       caratt2 = charFunction(sigmat(i-1),yf(i-1),kappa,eta);
       caratt = @(u) caratt1(u)./caratt2(u);
       P = cdfFFT([yf(i),yf(i-1)],caratt,XX);
    end
    
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
        disp("found nan");
    end
    
    F(:,i+1) = F(:,i)+X';
end

payoff = max(F(:,end)-K,0);

% Lastly, we generate the price and its confidence interval 
price = B*mean(payoff);
[~,~,CI] = normfit(payoff);

end