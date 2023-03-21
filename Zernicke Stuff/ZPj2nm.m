function [ n, m ] = ZPj2nm( j )
%ZPJ2NM Converts between standard and Noll indexing of the Zernicke
%polynomials

    n = floor(sqrt(2*j - 7/4) - 1/2);
    floorJ = 1/2*n.^2 + 1/2*n + 1;
    m = -n + 2*(j - floorJ);

end

