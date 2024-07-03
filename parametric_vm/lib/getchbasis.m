function [ B ] = getchbasis(th_ax,order,angle)
%GETCHBASIS Summary of this function goes here
%   Detailed explanation goes here
% N = 180
% th_ax=(0:2*pi/N:2*pi*(1-1/N))';
th_ax = double(th_ax);
order = double(order);
angle = double(angle);
if nargin==3
    B=zeros(length(th_ax),order+1);
    for n=0:order
        B(:,n+1)=cos(n*(th_ax-angle));
    end
else
    Acos=zeros(length(th_ax),order+1);
    Asin=zeros(length(th_ax),order+1);
    for n=0:order
       Acos(:,n+1)=cos(n*(th_ax));
       Asin(:,n+1)=sin(n*(th_ax));
    end 
    B=[Acos,Asin];
end
end
