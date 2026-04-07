function J = sir_jacobian(S, I, R, k, beta, tau, L)
%SIR_JACOBIAN  Jacobian of the SIR right-hand side at a given state.
%   Returns the 3-by-3 Jacobian matrix J_F = d(F_S,F_I,F_R)/d(S,I,R)
%   of the SIR model with demography at the state (S,I,R) and parameters
%   (k, beta, tau, L).  Used by the forward sensitivity equations (FSE)
%   in Chapter 4 and the adjoint ODE in Chapter 6.
%
%   J = SIR_JACOBIAN(S, I, R, K, BETA, TAU, L) returns the 3x3 Jacobian.
%
%   Inputs:
%       S, I, R - state values (scalars, all >= 0)
%       k       - contact rate (positive scalar)
%       beta    - transmission probability (in (0,1))
%       tau     - mean infectious period in days (positive scalar)
%       L       - mean lifespan in days (positive scalar)
%
%   Outputs:
%       J - 3x3 Jacobian matrix (dF/d[S,I,R])
%           J(i,j) = d F_i / d x_j, where x = [S; I; R]
%
%   Example:
%       p  = sir_nominal();
%       J0 = sir_jacobian(p.S0, p.I0, p.R0_ic, p.k, p.beta, p.tau, p.L);
%
%   Algorithm:
%       Exact analytic derivatives of eqs. (4.1)-(4.3).
%       N = S + I + R is conserved (constant total population).
%
%   Reference: Arriola & Hyman, SIAM 2026, eq. (4.16)-(4.17).
%   See also: SIR_MODEL, SIR_AUGMENTED

N     = S + I + R;
gamma = 1/tau;
mu    = 1/L;
lam   = k*beta*I/N;    % force of infection

% dF_S/d[S,I,R]
dFS_dS = -lam - mu;
dFS_dI = -k*beta*S/N + k*beta*S*I/N^2;   % = -k*beta*S*(N-I)/N^2 = -k*beta*S*R... simplified:
dFS_dI = -k*beta*S/N * (1 - I/N);        % cleaner form
dFS_dR = k*beta*S*I/N^2;

% dF_I/d[S,I,R]
dFI_dS = lam;
dFI_dI = k*beta*S/N * (1 - I/N) - (gamma + mu);
dFI_dR = -k*beta*S*I/N^2;

% dF_R/d[S,I,R]
dFR_dS = 0;
dFR_dI = gamma;
dFR_dR = -mu;

J = [dFS_dS, dFS_dI, dFS_dR;
     dFI_dS, dFI_dI, dFI_dR;
     dFR_dS, dFR_dI, dFR_dR];
end
