import numpy as np
from scipy.optimize import minimize
from pricing.callFFT import callFFT, computeI0
from pricing.addLogistic import priceAddLogistic


def calibrateAddBachelier(
    prices_norm: np.ndarray, moneyness_norm: np.ndarray, alpha=1 / 3
) -> tuple[float, float, float]:
    def dist(rho: np.ndarray) -> float:
        kappa, eta = rho[0], rho[1]
        return np.sum((prices_norm - callFFT(moneyness_norm, kappa, eta)) ** 2)

    res = minimize(
        dist, [1, 0.2], method="Nelder-Mead", options={"xatol": 1e-8, "disp": False}
    )
    kappa, eta = res.x

    I0 = computeI0(kappa, eta)

    return kappa, eta, I0


def calibrateAddLogistic(
    prices: np.ndarray,
    strikes: np.ndarray,
    F: np.ndarray,
    yf: np.ndarray,
    J_index: np.ndarray,
) -> tuple[float, float]:
    # prices must not be normalized

    def dist(rho: np.ndarray) -> float:
        sigma, H = rho[0], rho[1]
        s: float = yf[J_index[:].astype(int)] ** H * sigma

        return np.sum(
            (prices - priceAddLogistic(strikes, F[J_index[:].astype(int)], s)) ** 2
        )

    res = minimize(
        dist, [20, 0.5], method="Nelder-Mead", options={"xatol": 1e-8, "disp": False}
    )
    sigma, H = res.x

    return sigma, H
