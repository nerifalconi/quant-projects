import numpy as np
from scipy.interpolate import CubicSpline
from .callFFT import callFFT
from utils.charFunction import charFunction, charFunctionADL


def cdfFFT(
    phi: callable, t: list[float], xx: np.ndarray
) -> tuple[np.ndarray, np.ndarray]:
    """
    Compute the CDF using FFT. Returns (P, zk), with P as the CDF values at zk grid.
    """
    M = 15
    x1 = -5 * np.sqrt(t[1] - t[0])
    N = 2**M
    dx = -2 * x1 / (N - 1)
    dz = 2 * np.pi / (N * dx)

    j = np.arange(N)
    zk = -dz * (N - 1) / 2 + dz * j  # frequency grid
    xk = x1 + dx * j  # space grid

    a = -0.001
    y = phi(xk - 1j * a) / (1j * xk + a)
    fj = np.exp(-1j * (-dz * (N - 1) / 2) * dx * j) * y

    integral = np.fft.fft(fj)
    integral = np.real(dx * np.exp(-1j * x1 * zk) * integral)

    P = -CubicSpline(zk, integral, extrapolate=False)(xx) * np.exp(-xx * a) / (2 * np.pi)

    return P, zk


def _mc_framework(phi_funcs: list, t_grid: list, xx: np.ndarray, F0: float) -> np.ndarray:
    N = int(1e6)
    F = np.zeros((N, len(t_grid) + 1))
    F[:, 0] = F0
    np.random.seed(42)

    P_cache = {}
    for i in range(len(t_grid)):
        if i == 0:
            phi = phi_funcs[i]
            P, zk = cdfFFT(phi, [0, t_grid[i]], xx)
        else:
            key = (i - 1, i)
            if key not in P_cache:
                phi_ratio = lambda x: phi_funcs[i](x) / phi_funcs[i - 1](x)
                P, zk = cdfFFT(phi_ratio, [t_grid[i - 1], t_grid[i]], xx)
                P_cache[key] = (P, zk)
            else:
                P, zk = P_cache[key]

        # Ensure strictly increasing P for spline
        P_unique, idx = np.unique(P, return_index=True)
        xx_unique = xx[idx]

        U = np.random.uniform(P_unique.min(), P_unique.max(), N)
        spline = CubicSpline(P_unique, xx_unique, extrapolate=True)
        X = spline(U)

        F[:, i + 1] = F[:, i] + X

    return F


def mc_frameworkAB(
    kappa: float, eta: float, yf: np.ndarray, F0: float, sigmat: np.ndarray
) -> np.ndarray:
    phi_funcs = [charFunction(sigmat[i], yf[i], kappa, eta) for i in range(len(yf))]
    xx = np.arange(-100, 100, 0.001)
    return _mc_framework(phi_funcs, yf, xx, F0)


def mc_frameworkAL(b: np.ndarray, yf: np.ndarray, F0: float) -> np.ndarray:
    phi_funcs = [charFunctionADL(b[i]) for i in range(len(yf))]
    xx = np.arange(-100, 100, 0.001)
    return _mc_framework(phi_funcs, yf, xx, F0)


def _get_required_params(params: dict, required_keys: list) -> tuple:
    try:
        return tuple(params[key] for key in required_keys)
    except KeyError as e:
        raise ValueError(f"Missing parameter: {e} in the model parameters.")


def _price_option(model: str, params: dict, payoff_func) -> tuple[float, np.ndarray]:
    models = {"AddBachelier": _price_addbachelier, "AddLogistic": _price_addlogistic}
    if model not in models:
        raise ValueError(f"Model {model} is not recognized.")
    return models[model](params, payoff_func)


def _price_addbachelier(params: dict, payoff_func) -> tuple[float, np.ndarray]:
    kappa, eta, yf, F0, sigmat, B = _get_required_params(
        params, ["kappa", "eta", "yf", "F0", "sigmat", "B"]
    )
    F = mc_frameworkAB(kappa, eta, yf, F0, sigmat)
    K = params.get("K", F0)
    price = B * payoff_func(F, K)
    mu, sigma = np.mean(price), np.std(price)
    CI = mu + np.array([-1.96, 1.96]) * sigma / np.sqrt(len(price))
    return mu, CI


def _price_addlogistic(params: dict, payoff_func) -> tuple[float, np.ndarray]:
    sigma, H, yf, F0, B = _get_required_params(params, ["sigma", "H", "yf", "F0", "B"])
    b = (1 - np.exp(-yf * (sigma / 100) ** (1 / H))) ** H
    F = mc_frameworkAL(b, yf, F0)
    K = params.get("K", F0)
    price = B * payoff_func(F, K)
    mu, sigma = np.mean(price), np.std(price)
    CI = mu + np.array([-1.96, 1.96]) * sigma / np.sqrt(len(price))
    return mu, CI


def priceEuropean(model: str, params: dict) -> tuple[float, np.ndarray]:
    return _price_option(model, params, lambda F, K: np.maximum(F[:, -1] - K, 0))


def priceAsianDigital(model: str, params: dict) -> tuple[float, np.ndarray]:
    return _price_option(
        model, params, lambda F, K: (np.mean(F[:, 1:], axis=1) > K).astype(float)
    )
