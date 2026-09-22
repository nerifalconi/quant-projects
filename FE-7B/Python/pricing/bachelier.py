import numpy as np
from scipy.stats import norm
from scipy.optimize import minimize_scalar


def c_b(y: np.ndarray, sigma: float) -> np.ndarray:
    """
    Bachelier call option price
    :param y: strike - forward
    :param sigma: volatility
    :return: call price
    """
    return -y * norm.cdf(-y / sigma) + sigma * norm.pdf(-y / sigma)


def priceBachelier(x: np.ndarray, t: float, sigma: float, B: float) -> np.ndarray:
    return B * sigma * np.sqrt(t) * c_b(x / (sigma * np.sqrt(t)), 1.0)


def impliedVolatilityBachelier(
    moneyness: np.ndarray,
    callPrices: np.ndarray,
    yf: float,
    B: float,
) -> tuple[np.ndarray, np.ndarray]:
    """
    Vectorized default signature; we loop explicitly to mirror MATLAB.
    strikes, callPrices, F, yf, B, sigmaATM must all be the same shape.
    Returns implied vols of the same shape.
    """
    mask = ~np.isnan(callPrices)  # True where callPrices is *not* NaN
    callPrices = callPrices[mask]
    moneyness = moneyness[mask]

    implied_vols = np.zeros_like(moneyness, dtype=float)

    for i in range(len(callPrices)):

        def objective(sigma: float) -> float:
            return (priceBachelier(moneyness[i], yf, sigma, B) - callPrices[i]) ** 2

        sol = minimize_scalar(
            objective,
            bounds=(1e-6, 1e4),
        )
        implied_vols[i] = sol.x

    return (moneyness, implied_vols)
