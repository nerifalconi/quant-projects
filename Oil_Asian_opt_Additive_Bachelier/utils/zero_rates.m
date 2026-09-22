function zeroRates = zero_rates(yf, B, plot_flag)
% Computing zero rates in accordance to the standard definiton z =
% -log(B)/yf
% INPUTS:
% yf -> array, yearfrac between today and expiry
% B  -> array, discount factors
% plot_flag -> bool, plotting flag

zeroRates = -log(B)./yf;

if plot_flag
    figure;
    plot(yf, zeroRates, "-*", 'LineWidth',1.5);
    grid on; title("Zero Rates");
    xticks(yf); xlabel("Years");
end

end