# Additive Bachelier Model for Exotic Oil Options

Team project (3 students) — *Financial Engineering*, MSc in Mathematical Engineering (Quantitative Finance), Politecnico di Milano, A.Y. 2024/2025.

Contributors: Matteo Campagnoli, Neri Falconi, Federico Savini.

## Context

Standard Black–Scholes-type models cannot produce negative underlying prices, yet on 20 April 2020 the WTI crude oil futures contract for May delivery collapsed to **−$37.63/barrel** — the first time oil futures ever traded negative. In this project we calibrate the **Additive Bachelier model** and the **Additive Logistic model** — both of which allow negative underlying prices — to European WTI options quoted on 2 June 2020, in the immediate aftermath of that event.

## Method

1. **Bootstrap** — recovered discount factors and zero rates from synthetic forwards (long call + short put at the same strike), using linear regression on put-call parity across nine option maturities.
2. **Additive Bachelier calibration** — computed ATM Bachelier volatilities from market data, then priced options across the full strike range via a **Fast Fourier Transform (Lewis' method)** applied to the characteristic function of the additive process. Calibrated the remaining model parameters (κ, η) by minimizing the mean squared error against quoted market prices.
3. **Additive Logistic calibration** — calibrated the self-similar logistic additive model (SSLA) as an alternative to the Bachelier dynamics, following the same MSE-minimization approach.
4. **Fast Monte Carlo simulation** — used the Lévy–Khintchine representation to derive the CDF of the process via FFT, then generated price paths by inverting the CDF (spline interpolation), validating the result against the FFT pricing.
5. **Exotic option pricing & hedging** — priced an Asian-style digital option on the simulated paths, then constructed a Greeks-based static hedge using vanilla options and forward contracts, and back-tested it.

## Key results

| | |
|---|---|
| Calibrated Additive Bachelier parameters | κ = 0.8696, η = −0.005394 |
| Additive Logistic parameters | H = 0.3349, σ = 8.3179 |
| Digital option price | 0.49925 (Bachelier) vs. 0.49720 (Logistic) |
| MC vs. FFT pricing | Prices match almost exactly across all strikes |
| Hedged portfolio | **+2.74% return** over 10 trading days, materially lower P&L volatility than the unhedged position |

## Tools

Python (NumPy, SciPy), MATLAB.

## Reference

Roberto Baviera, Michele Domenico Massaria. *The Additive Bachelier Model with an Application to the Oil Option Market in the Covid Period.* Technical report, Politecnico di Milano, April 2025.
