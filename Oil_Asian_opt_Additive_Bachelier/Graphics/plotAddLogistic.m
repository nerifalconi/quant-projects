function plotAddLogistic(yf,sigmaATM,sigmaADL)


plot(yf,sigmaADL,"LineWidth",1.5);
hold on; grid on;
plot(yf,sigmaATM,"LineWidth",1.5);
title("Sigma At The Money (ATM)");
legend(["Additive Logistic","Market"]);
xlabel("Years");


end