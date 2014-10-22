function [Xnorm] = normalise(X)
% Normalises X to the interval [-1,1]. Algorithm taken from soundsc code.
xmin = min(X(:));
xmax = max(X(:));
dx = xmax-xmin;
if dx==0,
    % Protect against divide-by-zero errors:
    Xnorm = zeros(size(X));
else
	Xnorm = (X-xmin)/dx*2-1;
end