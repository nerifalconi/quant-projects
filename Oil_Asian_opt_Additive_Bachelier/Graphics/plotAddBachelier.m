function plotAddBachelier(yf, kappa, kappas, eta, etas, MSEs)

figure;
plot(yf,etas, "-*",'LineWidth',1.5,'Color','Green');
grid on; hold on;
plot(yf,eta*ones(length(etas),1),'LineWidth',1.5);
xlabel("Years");
legend(["$\eta_t$ - by date","$\eta$ - global"],'Interpreter', 'latex', 'FontSize', 14);
title("Additive Bachelier Calibration - \eta_t");

figure;
plot(yf,kappas, "-*","LineWidth",1.5,"Color","Blue");
grid on; hold on;
plot(yf,kappa*ones(length(etas),1),'LineWidth',1.5); 
xlabel("Years");
legend(["$\kappa_t$ - by date","$\kappa$ - global"],'Interpreter', 'latex', 'FontSize', 14);
title("Additive Bachelier Calibration - \kappa_t");

figure;
semilogy(yf,MSEs, "-*","LineWidth",1.5);
grid on;
title("MSE - Term Structure"); xlabel("Years");

end