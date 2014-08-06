function [W,H,p] = plsa_em(S,c)
% PLSA_EM performs NMF using an equivalent Probabilistic Latent Semantic
%   Analysis (PLSA) algorithm, using an Expectation Maximisation (EM)
%   method. Outlined by P. Smaragdis, ?From learning music to learning to
%   separate,? in Forum Acusticum, 2005.
%   S - input STFT of signal to factorise.
%   c - no. components
%   W - spectra components
%   H - spectra envelope
[F,T] = size(S);
G = zeros(c,F,T);
W = zeros(c,F);
H = zeros(c,T);
for i=1:c
    for f=1:F
        for t=1:T
            G(t,f,t) = W(i,f) * H(i,t);
        end
    end
end