import numpy as np


def priceAddLogistic(
    strike: np.ndarray | float,
    F: np.ndarray | float,
    s: np.ndarray | float,
    option_type: str = "Call",
) -> np.ndarray | float:
    """
    Price a call option using the logistic distribution.

    Parameters:
        strike (np.ndarray | float): Strike price(s).
        fwd (np.ndarray | float): Forward price(s).
        s (np.ndarray | float): Volatility(s).

    Returns:
        np.ndarray | float: Call option price(s).
    """
    if option_type == "Call":
        return s * np.log(1 + np.exp((F - strike) / s))
    elif option_type == "Put":
        return s * np.log(1 + np.exp((strike - F) / s))
    else:
        raise ValueError("Invalid option type. Use OptionType.CALL or OptionType.PUT.")
