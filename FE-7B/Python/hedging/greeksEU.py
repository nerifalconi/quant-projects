import numpy as np
from pricing.callFFT import callFFT


def delta(kappa, eta, yf, sigmaATM, B, F0, strike):
    bp = 1e-1

    x = (strike - F0) / (sigmaATM * np.sqrt(yf) * B)
    normPrice = callFFT(x, kappa, eta)

    x_up = (strike - bp - F0) / (sigmaATM * np.sqrt(yf) * B)
    normPrice_up = callFFT(x_up, kappa, eta)

    price = sigmaATM * np.sqrt(yf) * B * normPrice
    price_up = sigmaATM * np.sqrt(yf) * B * normPrice_up

    return (price_up - price) / bp


def vega(kappa, eta, yf, sigmaATM, B, F0, strike):
    bp = 1e-1

    x = (strike - F0) / (sigmaATM * np.sqrt(yf) * B)
    normPrice = callFFT(x, kappa, eta)

    x_up = (strike - F0) / ((bp + sigmaATM) * np.sqrt(yf) * B)
    normPrice_up = callFFT(x_up, kappa, eta)

    price = sigmaATM * np.sqrt(yf) * B * normPrice
    price_up = (sigmaATM + bp) * np.sqrt(yf) * B * normPrice_up

    return (price_up - price) / bp


def kappaCall(kappa, eta, yf, sigmaATM, B, F0, strike):
    bp = 1e-2

    x = (strike - F0) / (sigmaATM * np.sqrt(yf) * B)
    normPrice = callFFT(x, kappa, eta)
    normPrice_up = callFFT(x, kappa + bp, eta)

    price = sigmaATM * np.sqrt(yf) * B * normPrice
    price_up = sigmaATM * np.sqrt(yf) * B * normPrice_up

    return (price_up - price) / bp


def etaCall(kappa, eta, yf, sigmaATM, B, F0, strike):
    bp = 1e-2

    x = (strike - F0) / (sigmaATM * np.sqrt(yf) * B)
    normPrice = callFFT(x, kappa, eta)
    normPrice_up = callFFT(x, kappa, eta + bp)

    price = sigmaATM * np.sqrt(yf) * B * normPrice
    price_up = sigmaATM * np.sqrt(yf) * B * normPrice_up

    return (price_up - price) / bp
