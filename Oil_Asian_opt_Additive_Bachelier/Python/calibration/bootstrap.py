import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
from pathlib import Path
from sklearn.linear_model import LinearRegression
from scipy.interpolate import CubicSpline

from utils.utils import year_frac_act_x
from datetime import datetime


class ETL:
    def __init__(self, path_call: str, path_put: str):
        self._path_call = Path(path_call)
        self._path_put = Path(path_put)
        self._calls = {}
        self._puts = {}
        self._experies = []

    @classmethod
    def load(cls, path_call: str, path_put: str) -> "ETL":
        instance = cls(path_call, path_put)
        instance.load_data()
        return instance

    def load_data(self):
        for file in self._path_call.glob("*.csv"):
            df = pd.read_csv(file, sep=";", header=0)
            self.calls[file.stem] = df
            self.calls[file.stem].reset_index(drop=True, inplace=True)
            self.calls[file.stem].index = self.calls[file.stem]["ValueDate"]
            self.calls[file.stem].drop(columns=["ValueDate"], inplace=True)
            self.calls[file.stem].index.name = "Value Date"

        for file in self._path_put.glob("*.csv"):
            df = pd.read_csv(file, sep=";", header=0)
            self.puts[file.stem] = df
            self.puts[file.stem].reset_index(drop=True, inplace=True)
            self.puts[file.stem].index = self.puts[file.stem]["ValueDate"]
            self.puts[file.stem].drop(columns=["ValueDate"], inplace=True)
            self.puts[file.stem].index.name = "Value Date"

        if self.calls.keys() != self.puts.keys():
            raise ValueError("The call and put files do not match.")

        self._expiries = sorted(list(self.calls.keys()))

    @property
    def calls(self):
        return self._calls

    @property
    def puts(self):
        return self._puts

    @property
    def strikes(self) -> np.ndarray:
        return np.array([float(K) for K in self._calls[self._expiries[0]].columns.values])

    @property
    def expiries(self) -> list[str]:
        return self._expiries

    def value_date(self, date_str: int) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
        prices_call = np.array(
            [self._calls[expiry].loc[date_str].values for expiry in self._expiries]
        )
        prices_put = np.array(
            [self._puts[expiry].loc[date_str].values for expiry in self._expiries]
        )

        prices_fwd = np.array([call - put for call, put in zip(prices_call, prices_put)])

        return (prices_call, prices_put, prices_fwd)


def bootstrap(
    calls: np.ndarray, puts: np.ndarray, strikes: np.ndarray
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    N: int = len(calls)
    discounts = np.zeros(N)
    fwd_atm = np.zeros(N)
    call_atm = np.zeros(N)

    for i in range(N):
        A = pd.DataFrame(
            {
                "strikes": strikes,
                "prices_call": calls[i][:],
                "prices_put": puts[i][:],
            }
        )
        A.dropna(inplace=True)

        G = A["prices_call"] - A["prices_put"]

        lr = LinearRegression().fit(A["strikes"].values.reshape(-1, 1), G.values)

        discounts[i] = -lr.coef_[0]

        # fwd_atm.append(A["prices_fwd"]/discounts[i]+A["strikes"]) -> constant in strike
        fwd_atm[i] = lr.intercept_ / discounts[i]

        f = CubicSpline(A["strikes"], A["prices_call"])
        call_atm[i] = f(fwd_atm[i])

    return discounts, fwd_atm, call_atm


def zero_rates(
    discounts: np.ndarray, expiries: list[datetime], today: datetime
) -> np.ndarray:
    """
    Calculate zero rates from the discount factors.
    :param expiries: list of expiries
    :param discounts: array of discount factors
    :return: array of zero rates
    """
    yf = np.array([year_frac_act_x(today, d) for d in expiries])
    return -np.log(discounts) / yf


def sigma_atm(
    call_atm: np.ndarray, discounts: np.ndarray, expiries: list[datetime], today: datetime
) -> np.ndarray:
    """
    Calculate ATM volatilities from the forward ATM prices.
    :param fwd_atm: array of forward ATM prices
    :param strikes: array of strikes
    :param expiries: list of expiries
    :param today: today's date
    :return: array of ATM volatilities
    """
    yf = np.array([year_frac_act_x(today, d) for d in expiries])
    return np.sqrt(2 * np.pi / yf) * call_atm / discounts
