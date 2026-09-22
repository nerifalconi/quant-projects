function Ik = I0funct(x,k, eta)
% Computes call prices using FFT method
% Inputs:
%   xx        - Vector of log-moneyness values (log(K/F0))
%   phi       - Function handle of the characteristic function of the model
%   discount  - Discount factor for option maturity
%   F0        - Forward price of the underlying
%   M         - Determines the number of FFT points (N = 2^M)
%   dz        - Frequency step size in the Fourier domain
%
% Outputs:
%   prices    - Vector of call option prices corresponding to the input xx grid

M=15;
dz=0.0025;
N = 2^M;
dx = 2 * pi / (N * dz);

% Lower bounds for frequency (z) and space (x) grids
z1 = -dz * (N - 1) / 2;
x1 = -dx * (N - 1) / 2;
a=(1/4);
j = 0:N-1;
zk = z1 + dz * j;
xk = x1 + dx * j;
phi= charFunction(1,1,k,eta);
y =@(csi)  phi(csi - 1i*a) ./ (1i.*csi + a).^2;


% Compute FFT of the modified characteristic function
fj = exp(-1i * z1 * dx .*j) .* arrayfun(y,xk);
fhat = dx .* exp(-1i .* x1 .* zk) .* fft(fj).*exp(-zk*a);

Ik = interp1(zk, fhat, x);    % Interpolate to desired strikes
Ik=real((Ik)./(2*pi)^(1/2));

end