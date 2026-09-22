function gamma = gamma_complex(z)
% Gamma Function with support for complex arguments.
% The built-in Matlab implementation does not support complex arguments.
% The MathWorks documentation suggest to declare the arguments as symbolic,
% using the Symbolic Toolbox. We have found that this approach is slower
% than our custom implementation.

M = 10000;

gamma = zeros(1,length(z));
for k=1:length(z)
    f = @(t) exp(-t).*t.^(z(k)-1);
    gamma(k) = quadgk(f,0,M);
end

end
