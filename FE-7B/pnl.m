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
ACT_365 = 3;

% Hedging strategy is loaded from the output of the runProject, saved in
% the hedge.mat file

load("hedge.mat");
weights = results.weights;
strikeoption = results.strike;
quantasian = results.num_asian;

%% ETL - Read Call&Put data

callPath = "Data/datacalls";
putPath = "Data/dataputs";

ptf_nohedge = zeros(1,10);
ptf_hedge = zeros(1,10);

tic;
for i=1:10
    fprintf("Processing date %s\n",today);

    [strikes,calls,puts] = readData(callPath, putPath, snapRow);
    yf = yearfrac(today, expiries, ACT_365);

    [M,~] = size(calls);
    B = zeros(1,M);
    F = zeros(1,M);
    callATM = zeros(1,M);
    
    for k=1:M
        [B(k),F(k)] = bootstrap(strikes,calls(k,:),puts(k,:));
        callATM(k) = atmDATA(strikes,calls(k,:),puts(k,:),B(k),F(k));
    end
    sigmaATM = sigma_atm(callATM,yf,B,false);

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

    [kappa,eta,sigmat,MSE] = calibrateAddBachelier(marketNormMoneyness, marketNormCalls, sigmaATM);
    [ptf_nohedge(i),~] = exoticADB(kappa,eta,yf,F(end),sigmat,strikeoption,B(end));
    
    ptf_hedge(i) = quantasian*ptf_nohedge(i)+sum(weights.*[F(end),calls(end,76),puts(end,72)]);

    snapRow = snapRow + 1;
    today = today + 1;
end
toc;

%%

pnl_nohedge = (ptf_nohedge(2:end)-ptf_nohedge(1:end-1))./ptf_nohedge(1:end-1);
pnl_hedge = (ptf_hedge(2:end)-ptf_hedge(1:end-1))./ptf_hedge(1:end-1);

figure;
plot(1:10,ptf_hedge,"LineWidth",1.5,"LineStyle","--"); grid on;

figure;
plot(1:9,pnl_nohedge,"LineWidth",1.5,"LineStyle","--");
hold on; grid on;
plot(1:9,pnl_hedge,"LineWidth",1.5);
title("Profit & Loss");
legend(["Asian","Hedged"]);