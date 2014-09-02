function [W,H,p] = plsa_em(S,c,Winit,Hinit)
% PLSA_EM performs NMF using an equivalent Probabilistic Latent Semantic
%   Analysis (PLSA) algorithm, using an Expectation Maximisation (EM)
%   method. Outlined by P. Smaragdis, ?From learning music to learning to
%   separate,? in Forum Acusticum, 2005.
%   S - S(f,t) input STFT of signal to factorise (f~frequency, t~time)
%   c - no. components
%   W - W(f,i) spectra components (f~frequency, i~component)
%   H - H(t,i) spectra envelope (t~time, i~component)
%   p - weights of each marginal pair product
%   Winit - initial value for W (optional, defaults to ones)
%   Hinit - initial value for H (optional, defaults to ones)
%
% Written by Ashley Gillman

% Initialise variables
[F,T] = size(S);
G = zeros(F,T,c);
update = zeros(F,T,c);
p = ones(c,1);

if nargin == 2
    W = ones(F,c);
    H = ones(T,c);
elseif nargin == 4
    W = Winit;
    H = Hinit;
else
    error('Wilson:plsa_em:InvalidNoArguments', ...
        'Must specify no initial values or both.')
end

% Iterations
done = false;
while ~done
    % UPDATE
    for f=1:F
        for t=1:T
            for i=1:c
                % G_i(f,t) = W_i(f)H_i(t)
                % ensure linear ops
                assert(all(size(W(f,i))==[1 1]));
                assert(all(size(H(f,i))==[1 1]));
                G(f,t,i) = W(f,i) * H(t,i);
                
                % update = \frac{G_i(f,t)*S(f,t)}{\sum_i G_i(f,t)}
                assert(all(size(G(f,t,i))==[1 1]));
                assert(all(size(S(f,t))==[1 1]));
                update(f,t,i) = G(f,t,i) * S(f,t);
            end
            update(f,t,:) = update(f,t,:) / sum(G(f,t,:));
        end
    end
    % W_i(f) = \sum_{all t}\frac{G_i(f,t)*S(f,t)}{\sum_i G_i(f,t)}
    W = squeeze(sum(update,2));
    % H_i(t) = \sum_{all f}\frac{G_i(f,t)*S(f,t)}{\sum_i G_i(f,t)}
    H = squeeze(sum(update,1));
    
    % NORMALISE
    for i=1:c
        p(i) = sum(W(:,i));
        assert(all(p(i) == sum(H(:,i))))
        W(:,i) = W(:,i) / p(i);
        H(:,i) = H(:,i) / p(i);
    end
    done = true;
end