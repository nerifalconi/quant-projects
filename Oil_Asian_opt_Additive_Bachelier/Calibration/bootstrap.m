function [B,F] = bootstrap(K, C, P)
% Bootstrapping technique based on synthetic forward reconstruction.
% For more detail, read the paper by Baviera&Azzone:
% "Synthetic forwards and cost of funding in the equity derivative market".
% INPUTS:
% K -> array, strike prices in the market
% C -> array, call prices in the market
% P -> array, put prices in the market
% 

if length(C) ~= length(P)
    error("Calls and Puts must have the same length!");
end

% To ensure the condition above, we reccomend to always pass the whole
% market data and let this function drop the nans.

m = ~isnan(C) & ~isnan(P);

% We only consider when the Call-Put pair is traded, since we use put-call
% parity relation to compute the synthetic forward

K = K(m).'; C = C(m).'; P = P(m).';

G = C - P;
beta = [K ones(size(K))] \ G;
B = -beta(1); F = beta(2)/B;
end
