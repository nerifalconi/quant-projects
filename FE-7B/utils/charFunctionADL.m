function phi = charFunctionADL(b)
% Characteristic function of the Additive Logistic Model.
% The definition requires the use of Beta function, valued on a complex
% number. However, built-in MATLAB implementation of Beta does not support
% complex numbers as argument, hence we had to define our own custom one.
% THIS METHOD RETURNS A FUNCTION HANDLE
% INPUTS:
% b -> vector, parameter term structure of the ADL

phi = @(z) (1-b).*beta_complex(1+(1i.*z-1).*b,1-1i.*z.*b);

end