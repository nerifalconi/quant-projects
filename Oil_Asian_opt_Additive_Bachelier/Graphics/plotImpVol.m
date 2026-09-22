function plotImpVol(moneynessRed, impvol, marketMoneyness, marketImpliedVol, sigmaATM, yf)

figure;
tl = tiledlayout(2, 4, 'Padding', 'compact', 'TileSpacing', 'compact');

for k = 1:length(yf)
    I = impvol * sigmaATM(k);
    x = moneynessRed * sqrt(yf(k)) * sigmaATM(k);

    q = marketMoneyness(num2str(k));
    p = marketImpliedVol(num2str(k));

    if k == 8
        q = q(2:end);
        p = p(2:end);
    end

    x_interp = min(q):0.1:20;
    I_interp = spline(x, I, x_interp);
    % sigmacall(k) = spline(x, I, -0.18);
    % sigmaput(k) = spline(x, I, -2.82);
    p_interp = spline(q, p, x_interp);

    nexttile;
    plot(x_interp, I_interp, 'LineWidth', 1.5, 'Color', 'Blue');
    hold on; grid on;
    plot(x_interp, p_interp, 'LineWidth', 1.5, 'Color', 'Red');
    xlim([-25, 25]);
end

end