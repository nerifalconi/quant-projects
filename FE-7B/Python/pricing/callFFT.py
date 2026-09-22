import numpy as np
from utils.charFunction import charFunction


def computeI0(kappa: float, eta: float) -> float:
    M = 15
    dz = 0.0025
    N = 2**M
    dx = 2 * np.pi / (N * dz)

    z1 = -dz * (N - 1) / 2
    x1 = -dx * (N - 1) / 2
    a = 0.25

    j = np.arange(N)
    zk = z1 + dz * j  # length N
    xk = x1 + dx * j  # length N

    phi = charFunction(1.0, 1.0, kappa, eta)

    # sample integrand on xk
    csi = xk.astype(np.complex128)
    y = phi(csi - 1j * a) / (1j * csi + a) ** 2
    fj = np.exp(-1j * z1 * dx * j) * y

    # FFT + phase‐shift + frequency‐damping
    Fhat = np.fft.fft(fj)
    Fhat *= dx * np.exp(-1j * x1 * zk) * np.exp(-zk * a)

    # now interpolate back onto the strike/log‐moneyness grid x
    Ik = np.interp(0, zk, Fhat.real)

    # only here do we apply any damping in x
    return Ik / np.sqrt(2 * np.pi)


def callFFT(x: np.ndarray, kappa: float, eta: float, alpha: float = 1 / 2) -> np.ndarray:
    M = 15
    dz = 0.0025
    N = 2**M
    dx = 2 * np.pi / (N * dz)

    z1 = -dz * (N - 1) / 2
    x1 = -dx * (N - 1) / 2
    a = 0.5

    j = np.arange(N)
    zk = z1 + dz * j  # frequency grid
    xk = x1 + dx * j  # space grid (used in integrand)

    I0 = computeI0(kappa, eta)

    phi = charFunction(1 / I0, 1, kappa, eta)

    # integrand y(csi) evaluated at csi = xk
    csi = xk.astype(np.complex128)
    y = phi(csi - 1j * a) / (1j * csi + a) ** 2
    fj = np.exp(-1j * z1 * dx * j) * y

    # FFT + phase shift + scaling
    Fhat = np.fft.fft(fj)
    Fhat = dx * np.exp(-1j * x1 * zk) * Fhat

    # interpolate Fhat (on grid zk) back to strikes x
    Ik = np.interp(x, zk, Fhat.real)

    # final real price
    return Ik / (2 * np.pi) * np.exp(-x * a)
