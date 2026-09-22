function [B,F] = bootstrapOne(callFile, putFile, snapRow)

% this shouldn't exists

    calls = readtable(callFile, 'ReadVariableNames', false);
    puts  = readtable(putFile , 'ReadVariableNames', false);

    K = calls{1,   2:end};
    C = calls{snapRow, 2:end};
    P = puts {snapRow, 2:end};

    m = ~isnan(C) & ~isnan(P);
    K = K(m).'; C = C(m).'; P = P(m).';

    G = C - P;
    beta = [K ones(size(K))] \ G;
    B = -beta(1); F = beta(2)/B;
end
