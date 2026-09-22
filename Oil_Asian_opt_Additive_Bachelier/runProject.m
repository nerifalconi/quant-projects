clc;
clear;
close all;

addpath("ETL");
addpath("Calibration/");
addpath("Pricing/");
addpath("Graphics");
addpath("Hedging/");
addpath("utils/");

%% Model Setting
today = datetime(2020,06,02);
% Expiries of all the Calls and Put in the dataset
expiries = [ datetime(2020,08,17), datetime(2020,11,17) ...
            datetime(2021,02,17), datetime(2021,05,17), datetime(2021,08,17) ...
            datetime(2021,11,16), datetime(2022,05,17), datetime(2022,11,16)];

snapRow = 108;

%% ETL - Read Call&Put data

callPath = "Data/datacalls";
putPath = "Data/dataputs";
[strikes,calls,puts] = readData(callPath, putPath, snapRow);

%% Bootstrap

[M,~] = size(calls);
B = zeros(1,M);
F = zeros(1,M);
callATM = zeros(1,M);

for k=1:M
    [B(k),F(k)] = bootstrap(strikes,calls(k,:),puts(k,:));
    callATM(k) = atmDATA(strikes,calls(k,:),puts(k,:),B(k),F(k));
end

%% ETL - Zero Rates

ACT_365 = 3;
yf = yearfrac(today, expiries, ACT_365);
zeroRates = zero_rates(yf, B, true);
sigmaATM = sigma_atm(callATM,yf,B,true);

%% Calibrate Bachelier Model

marketCalls = containers.Map();
marketNormCalls = containers.Map();
marketStrikes = containers.Map();
marketMoneyness = containers.Map();
marketNormMoneyness = containers.Map();
marketImpliedVol = containers.Map();

for k=1:length(B)
    [tmp_calls,tmp_strikes,tmp_vol] = ...
        calibrateBachelier(strikes,calls(k,:),puts(k,:),B(k),F(k), yf(k));

    tmp_money = tmp_strikes - F(k);
    mask = tmp_money > -30 & tmp_money < 30;

    marketCalls(num2str(k)) = tmp_calls(mask);
    marketMoneyness(num2str(k)) = tmp_money(mask);
    marketImpliedVol(num2str(k)) = tmp_vol(mask);

    marketNormMoneyness(num2str(k)) = tmp_money(mask)/(sigmaATM(k)*sqrt(yf(k))*B(k));
    marketNormCalls(num2str(k)) = tmp_calls(mask)/(sigmaATM(k)*sqrt(yf(k))*B(k));
    marketStrikes(num2str(k)) = tmp_strikes(mask);
end

%% Calibrate Additive Bachelier Model

[kappa,eta,sigmat,MSE] = calibrateAddBachelier(marketNormMoneyness, marketNormCalls, sigmaATM);

%% calibration for every t
% This function recalibrates the Additive Bachelier Model for every
% exipiry. It basically reruns the cell above nine times, restricting the
% calibration the relevant dates. Hence, it may take a while to run.

kappas = zeros(1,length(yf));
etas = zeros(1,length(yf));
MSEs = zeros(1,length(yf));

for i=1:length(yf)
    [kappas(i),etas(i),~,MSEs(i)] = calibrateAddBachelier(marketNormMoneyness(num2str(i)), marketNormCalls(num2str(i)), sigmaATM(i));
end

plotAddBachelier(yf,kappa,kappas,eta,etas,MSEs);

%% Calibrate Additive Logistic

[sigmaADL,b] = calibrateAddLogistic(marketStrikes, marketCalls, F, yf);

plotAddLogistic(yf,sigmaATM,sigmaADL);

%% Price Additive Bachelier 

[priceAD,F_AB] = exoticADB(kappa,eta,yf,F(end),sigmat,F(end),B(end));

disp("----- Exotic Option Pricing -----");
fprintf("Additive Bachelier Model price: %0.5f\n", priceAD);

for i=1:length(yf)
    fprintf("Additive Bachelier Model fwd T = %s: %d\n", expiries(i), F_AB(i));
end

%% Price SLA
% Warning! This function takes a while to execute. This is related to the
% beta function implementation for complex arguments. For more detail,
% check the documentation of the script "utils/beta_complex.m".

tic;
[priceSLA,F_SLA]=exoticADL(b,B(end),yf,F(end));
toc;

fprintf("Additive Logistic Model price: %0.5f\n", priceSLA);

for i=1:length(yf)
    fprintf("Additive Logistic Model fwd T = %s: %d\n", expiries(i), F_SLA(i));
end

%% Additive Bachelier Implied Vol
% Warning! This function may take some time, due to the high number of
% optimization routines. On our laptop it takes around 30 seconds.

tic;
[moneynessRed,impvol] = impvolAddBachelier(kappa,eta);
toc;

%%

plotImpVol(moneynessRed,impvol,marketMoneyness,marketImpliedVol,sigmaATM,yf);

%% Sensitivities
%Getting the traded Call and put with the strike more closer to the ATM
%value 
strike_call_liquid = 42;
strike_put_liquid = 40;

[sigmacall,sigmaput] = sigma_mkt(moneynessRed, impvol, sigmaATM(end), yf(end), F(end));

%Calculating the Vega,Delta, Sensitivities for the Vol of Vol and
%sensitivities for the Skewness for our Exotic Option
[vega,sens_kappa,sens_eta,delta] = sensitivitiesEx(kappa,eta,B(end),yf,F(end),sigmaATM,priceAD,sigmat);
disp("----- Hedging -----");
fprintf("Delta of Exotic Option: %0.5f\n",delta);
fprintf("Vega of Exotic Option: %0.5f\n",vega);
fprintf("Sens Kappa of Exotic Option: %0.5f\n",sens_kappa);
fprintf("Sens Eta of Exotic Option: %0.5f\n",sens_eta);

%% Hedging
%Calculating the Vega,Delta, Sensitivities for the Vol of Vol and
%sensitivities for the Skewness for the Call and Put options with the same
%TTM of our option 

tic;
[vega_Call,sens_kappa_call,sens_eta_call,delta_Call] = sensitivitiesCall(kappa, eta, yf(end), B(end), F(end), strike_call_liquid, sigmacall);
[vega_Put,sens_kappa_put,sens_eta_put,delta_Put] = sensitivitiesCall(kappa, eta, yf(end), B(end), F(end), strike_put_liquid, sigmaput);
delta_Put = delta_Put - B(end);

fprintf("Delta of Call options: %0.4f\n",delta_Call);
fprintf("Vega of Call Option: %0.4f\n",vega_Call);
fprintf("Sens Kappa of Call Option: %0.4f\n",sens_kappa_call);
fprintf("Sens Eta of Call Option: %0.4f\n",sens_eta_call);

% Creating a linear system to search the best Hedging possible 
Aeq = [1 , delta_Call, delta_Put; 0, vega_Call, vega_Put; 0, sens_eta_call, sens_eta_put; 0, sens_kappa_call, sens_kappa_put];
beq = [delta; vega;sens_eta;sens_kappa]*20e6;
x_opt = Aeq\beq;

%%
trans_cost_fwd = 1e-4;
trans_cost_options = 6e-4;

%  Function for calculating the 1 fwd, 2 call, 3 put
f = @(x) (abs(x(1)) * trans_cost_fwd + (abs(x(2)) + abs(x(3))) * trans_cost_options);

%Market cost of the most liquid Call and Put with strike respectively 42
%and 40
price_call_liquid = 7.73;
price_put_liquid = 6.54;

x_fwd = floor(x_opt(1)/F(end));
x_call = floor(x_opt(2)/(price_call_liquid));
x_put = floor(x_opt(3)/(price_put_liquid));

fprintf("Number of Forwards to be traded: %0.4f\n",x_fwd);
fprintf("Number of Calls with strike 42 to be traded: %0.4f\n",x_call);
fprintf("Number of Puts with strike 40 to be traded: %0.4f\n",x_put);

transaction_cost = f([x_fwd * F(end), x_call * price_call_liquid, x_put * price_put_liquid]);
transaction_cost = round(transaction_cost,3);
fprintf("Transaction cost of our Hedging %0.4f\n",transaction_cost);

%% Save results
results.weights = [x_fwd,x_call,x_put];
results.strike = F(end);
results.num_asian = 20e6/priceAD;
save("hedge.mat","results");
