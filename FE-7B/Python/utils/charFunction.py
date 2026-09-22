import numpy as np
from scipy.special import gamma


def psi(u: np.ndarray, kappa: float, eta: float, alpha: float = 1 / 3) -> np.ndarray:
    if alpha == 0:
        return -1 / kappa * np.log(1 + kappa * u)
    else:
        return (
            (1 / kappa)
            * (1 - alpha)
            / alpha
            * (1 - (1 + kappa * u / (1 - alpha)) ** alpha)
        )


def charFunction(
    sigma: float, t: float, kappa: float, eta: float, alpha=1 / 3
) -> callable:
    def cf(u):
        u = np.asarray(u, dtype=np.complex128)
        arg1 = 1j * u * eta * sigma * np.sqrt(t) + 0.5 * (u**2) * sigma**2 * t
        return np.exp(psi(arg1, kappa, eta, alpha) + 1j * u * eta * sigma * np.sqrt(t))

    return cf


def beta_complex(
    z: np.complex128 | np.ndarray, w: np.complex128 | np.ndarray
) -> np.complex128 | np.ndarray:
    """
    Compute the beta function for complex arguments.
    :param z: Complex number or array of complex numbers.
    :return: Beta function value.
    """
    return gamma(z) * gamma(w) / gamma(z + w)


def charFunctionADL(b: float):
    def cf(u):
        u = np.asarray(u, dtype=np.complex128)
        return (1 - b) * beta_complex(1 + (1j * u - 1) * b, 1 - 1j * u * b)

    return cf
