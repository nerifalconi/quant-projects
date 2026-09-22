from pricing.callFFT import computeI0
from pricing.callMC import priceAsianDigital


def sensVol(kappa, eta, yf, sigmaATM, B, F, strike, priceAB):
    bp = 1e-2

    sigmaATM_up = sigmaATM + bp
    I0 = computeI0(kappa, eta)

    paramsAB = {
        "kappa": kappa,
        "eta": eta,
        "B": B,
        "yf": yf,
        "F0": F,
        "K": strike,
        "sigmat": sigmaATM_up / I0,
    }

    price_up, _ = priceAsianDigital("AddBachelier", paramsAB)
    return (price_up - priceAB) / bp


def sensKappa(kappa, eta, yf, sigmaATM, B, F, strike, priceAB):
    bp = 1e-2

    kappa += bp
    I0 = computeI0(kappa, eta)
    paramsAB = {
        "kappa": kappa,
        "eta": eta,
        "B": B,
        "yf": yf,
        "F0": F,
        "K": strike,
        "sigmat": sigmaATM / I0,
    }

    price_up, _ = priceAsianDigital("AddBachelier", paramsAB)
    return (price_up - priceAB) / bp


def sensEta(kappa, eta, yf, sigmaATM, B, F, strike, priceAB):
    bp = 1e-2

    eta += bp
    I0 = computeI0(kappa, eta)
    paramsAB = {
        "kappa": kappa,
        "eta": eta,
        "B": B,
        "yf": yf,
        "F0": F,
        "K": strike,
        "sigmat": sigmaATM / I0,
    }

    price_up, _ = priceAsianDigital("AddBachelier", paramsAB)
    return (price_up - priceAB) / bp


def sensDelta(kappa, eta, yf, sigmaATM, B, F, strike, priceAB):
    bp = 1e-1

    I0 = computeI0(kappa, eta)
    paramsAB = {
        "kappa": kappa,
        "eta": eta,
        "B": B,
        "yf": yf,
        "F0": F + bp,
        "K": strike,
        "sigmat": sigmaATM / I0,
    }

    price_up, _ = priceAsianDigital("AddBachelier", paramsAB)
    return (price_up - priceAB) / bp
