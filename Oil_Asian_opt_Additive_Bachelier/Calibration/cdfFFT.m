function [P,zk] = cdfFFT(t,caratt,XX)
% Calculating the CDF of the distribution with  FFT.
% INPUTS:
% t -> vector, time where we calculate the CDF 
% caratt   -> function, Characteristic function of the Process
% XX-> vector,moneyness in which we interpolate for finding the final distribution
M=15;
x1=-5*sqrt(t(1)-t(2));
N = 2^M;
dx=-2*x1/(N-1);
dz = 2 * pi / (N * dx);

% Lower bounds for frequency (z) and space (x) grids
z1 = -dz*(N-1)/ 2;
j = 0:N-1;
zk = z1 + dz * j;
xk = x1 + dx * (j);
a=-0.0010;
y = caratt(xk-1i*a)./(xk.*1i+a);
fj = exp(-1i * z1 * dx *j).*y;

if class(fj) == "sym"
    fj = double(fj);
end

I=real(fft(fj).*dx.*exp(-1i * x1 * zk));
P=interp1(zk,I,XX,'spline');
P=-P.*exp(-XX*a)/(2*pi);
end