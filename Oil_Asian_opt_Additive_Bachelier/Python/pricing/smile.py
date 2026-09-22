import numpy as np
from scipy.optimize import fsolve
from .callFFT import callFFT
from .bachelier import c_b


def smileBachelier(kappa: float, eta: float) -> tuple[np.ndarray, np.ndarray]:
    moneynessRed = np.arange(-20, 22, 2)
    impvol = np.zeros(len(moneynessRed))

    initialCond = 20

    for k in range(len(moneynessRed)):

        def f(vol):
            return (c_b(moneynessRed[k], vol) - callFFT(moneynessRed[k], kappa, eta)) ** 2

        impvol[k] = fsolve(f, initialCond)

    return moneynessRed, impvol
