import datetime as dt
import numpy as np
from enum import Enum


class OptionType(Enum):
    CALL = "call"
    PUT = "put"


def year_frac_act_x(t1: dt.datetime, t2: dt.datetime, x: int = 365) -> float:
    """
    Compute the year fraction between two dates using the ACT/x convention.

    Parameters:
        t1 (dt.datetime): First date.
        t2 (dt.datetime): Second date.
        x (int): Number of days in a year.

    Returns:
        float: Year fraction between the two dates.
    """

    return (t2 - t1).days / x


def generate_full_grid(
    prices_call: np.ndarray,
    prices_put: np.ndarray,
    strikes: np.ndarray,
    fwd_atm: float,
    discount: float,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    mask1 = np.isnan(prices_call)
    mask2 = np.isnan(prices_put)

    prices_call[mask1] = prices_put[mask1] + discount * (fwd_atm - strikes[mask1])
    prices_put[mask2] = prices_call[mask2] + discount * (strikes[mask2] - fwd_atm)

    mask = np.isnan(prices_call) | np.isnan(prices_put)
    prices_call = prices_call[~mask]
    prices_put = prices_put[~mask]
    strikes = strikes[~mask]

    return prices_call, prices_put, strikes
