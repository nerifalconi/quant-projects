function beta = beta_complex(a,b)
% Beta Function with support for complex arguments.
% The built-in Matlab implementation does not support complex arguments.
% The MathWorks documentation suggest to declare the arguments as symbolic,
% using the Symbolic Toolbox. We have found that this approach is slower
% than our custom implementation.

beta = gamma_complex(a).*gamma_complex(b)./gamma_complex(a+b);

end