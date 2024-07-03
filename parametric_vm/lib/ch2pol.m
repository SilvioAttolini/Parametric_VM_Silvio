function [ th_ax,r ] = ch2pol(N,coeffs,orientation)
% CH2POL Summary of this function goes here
% Detailed explanation goes here
    % coeffs here must be passed as column vector
N = double(N);
coeffs = double(coeffs);
th_ax=(0:2*pi/N:2*pi*(1-1/N))';
B=getchbasis(th_ax,length(coeffs),orientation);
r=B*[1-sum(coeffs);coeffs];
end
