function prices = callFFT(x,k,eta)
% Normalized price of a European Call Option under the Additive Bachelier
% Model. The model leads to an integral expression for the price of a
% European Call, a generalization of Lewis Formula, which is here computed
% using the Fast Fourier Transform (FFT) algorithm. This implementation is
% highly vectorized and efficient. 
% INPUTS:
% x   -> vector or float, normalized moneyness
% k   -> float, vol of vol parameter
% eta -> float, skewness parameter

% FFT parameters and fundamental relations
M=15;
dz=0.0025;
N = 2^M;
dx = 2 * pi / (N * dz);

% Lower bounds for frequency (z) and space (x) grids
z1 = -dz * (N - 1) / 2;
x1 = -dx * (N - 1) / 2;
j = 0:N-1;
zk = z1 + dz * j;
xk = x1 + dx * j;

% The integrand function has a pole in the origin, which we shift away
% using a dumping parameter a. We've found that a = 1/2 works well.
a = 1/2;

% The characteristic function requires the quantiy I0, which is itself 
% computed descritizing a Lewis-like formula through FFT. Look at the
% implementation of I0 for more detail.
I0 = I0funct(0,k,eta);
phi = charFunction(1/I0,1,k,eta);
y = @(csi)  phi(csi - 1i*a)./ (1i*csi + a).^2;
fj = exp(-1i * z1 * dx *j) .* arrayfun(y,xk);
fhat = dx .* exp(-1i * x1 * zk) .* fft(fj);

% The FFT relations fix the moneyness on which the price is actually
% computed. The get the desidered moneynesses, we interpolated.
Ik = interp1(zk, fhat, x);
prices = real(Ik/(2*pi).*exp(-x.*a));

end