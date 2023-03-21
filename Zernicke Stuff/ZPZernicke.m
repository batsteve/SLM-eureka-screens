function [ u ] = ZPZernicke( j, r, theta )
%ZPZERNICKE Summary of this function goes here
%   Detailed explanation goes here
    
    [n, m] = ZPj2nm(j);

    diff = (n-abs(m))/2;
    radComp = zeros(size(r, 1), size(r, 2), diff+1);
    for k = 0:diff;
        radComp(:,:,k+1) = (-1).^k.*nchoosek(n-k, k).*nchoosek(n-2*k, diff-k).*r.^(n-2*k);
    end
    radPart = sum(radComp, 3);
    
    if (m>0)
        anglePart = cos(m*theta);
    else % (m<0)
        anglePart = sin(m*theta);
    end  

    u = radPart.*anglePart;
    
end

