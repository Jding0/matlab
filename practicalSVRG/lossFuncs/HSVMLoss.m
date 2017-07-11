function [f,g] = HuberSVMLoss(w,X,y,t)
% w(feature,1)
% X(instance,feature)
% y(instance,1)

[n,p] = size(X);

tau = y.*(X*w);

fi = zeros(n,1);
fi(tau < 1-t) = 1- tau(tau < 1-t);
fi(abs(1-tau) <= t) = (1+t-tau(abs(1-tau) <= t)).^2/4/t;

f= sum(fi);

if nargout > 1
    fp = zeros(size(y));
    fp(tau < 1-t) = -1;
    fp(abs(1-tau) <= t) = -1/2/t * (1+t-tau(abs(1-tau)<=t));
    g = X' * (fp.*y);
end
