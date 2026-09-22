function phi = charFunction(sigma,t, k, eta)
% Characteristic Function of the Additive Bachelier Model.
% The actual expression depends on the hyper parameter alpha. For typing
% simplicity, we have opted to not make alpha an actual function input,
% since it's always the same throughout the code and we didn't like how 
% MATLAB manages default arguments.
% THIS METHOD RETURNS A FUNCTION HANDLE
% INPUTS:
% sigma -> float, level of volatility at time t
% t -> float, time to maturity (year frac)
% k -> float, vol of vol
% eta -> float, skewness

% alpha = 1/2;
alpha = 1/3;

if alpha == 0
    % G is a Gamma distribution with parameters a and b
    psi = @(u) -1/k*log(1+k*u);
else
    % G is an Inverse Gaussian
    psi = @(u) 1/k*(1-alpha)/alpha*(1-(1+(u*k)./(1-alpha)).^alpha);
end
   
logphi = @(u) psi(1i*u*eta*sigma*sqrt(t)+u.^2/2*sigma.^2.*t)+ ...
              1i*u*eta*sigma.*sqrt(t);
phi = @(u) exp(logphi(u));

end