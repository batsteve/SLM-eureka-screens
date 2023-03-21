function [ corr ] = calcMGSMCrossCorrelation( x1, y1, x2, y2, z, d2, M, sigma ,lambda )
%CALCCROSSCORRELATION Summary of this function goes here
%   Detailed explanation goes here
    
    r1 = sqrt(x1^2 + y1^2 + z^2);
    s1sin = sqrt(x1^2 + y1^2)/r1;
    s1cos = sqrt(z^2)/r1;
    
    r2 = sqrt(x2^2 + y2^2 + z^2);
    s2sin = sqrt(x2^2 + y2^2)/r2;
    s2cos = sqrt(z^2)/r2;
    
    rDiff = sqrt((x1-x2)^2 + (y1-y2)^2);
    
    delta = sqrt(d2);
    k = 2*pi/lambda;
    
    accum = 0;
    for m = 1:M
        accum = accum + (-1)^(m-1)/m * ...
            factorial(M)/(factorial(m)*factorial(M-m));
    end
    C0 = accum;
    
    accum = 0;
    for m = 1:M
        am = (1/2)*(1/(2*sigma^2) + 1/(m*delta^2));
        bm = 1/(2*m*delta^2);
        alpham = am/(4*(am^2-bm^2));
        betam = bm/(4*(am^2-bm^2));
        accum = accum + (-1)^(m-1)/m * ...
            factorial(M)/(factorial(m)*factorial(M-m)) *...
            1/(am^2 - bm^2) *...
            exp(-k^2*(alpham*s1sin^2 + alpham*s2sin^2 - 2*betam*(s1sin*s2sin)));
    end
    shapeFactor = accum;
    
    W = (1/C0)*k^2* s1cos*s2cos* exp(1i*k*(rDiff))/(r1*r2) * shapeFactor;
    
    corr = W;

end

