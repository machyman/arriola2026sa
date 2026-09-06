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
%       N is the constant total population, held fixed (see eq. sirJacobian).
%
%   Reference: Arriola & Hyman, in preparation, eq. (4.16)-(4.17).
%   See also: SIR_MODEL, SIR_AUGMENTED

N     = S + I + R;
gamma = 1/tau;
mu    = 1/L;
lam   = k*beta*I/N;    % force of infection

% dF_S/d[S,I,R]
% Constant-N convention, matching eq. (sirJacobian) in the book: N is held
% fixed at the nominal total population, so the birth term mu*N contributes
% no state derivative.  Column sums are therefore -mu, not zero.  The book's
% equation is canonical; do not reintroduce d(mu*N)/dx here.
dFS_dS = -k*beta*I/N - mu;
dFS_dI = -k*beta*S/N;
dFS_dR =  0;

dFI_dS =  k*beta*I/N;
dFI_dI =  k*beta*S/N - (gamma + mu);
dFI_dR =  0;

dFR_dS = 0;
dFR_dI = gamma;
dFR_dR = -mu;

J = [dFS_dS, dFS_dI, dFS_dR;
     dFI_dS, dFI_dI, dFI_dR;
     dFR_dS, dFR_dI, dFR_dR];
end
