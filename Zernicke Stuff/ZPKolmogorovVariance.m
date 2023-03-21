function [ a2 ] = ZPKolmogorovVariance( j, Rratio )
%ZPKOLMAGOROVVARIANCE Returns the random variance associated with the j-th
%Zernicke Polynomial in the Zernicke representation of the Kolmagorov
%Spectrum.
%   Implementation taken from Noll 1976.  

    [n,~] = ZPj2nm(j);
    fac1 = (0.046/pi)*Rratio^(5/3)*(n+1);
    fac2 = 1;
    Inn = gamma(14/3)*gamma(n-5/6)/( 2^(14/3)*gamma(17/6)^2*gamma(n+23/6) );
    fac3 = (2*pi)^(-11/3)*Inn;

    a2 = fac1*fac2*fac3;
end

