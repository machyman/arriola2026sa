function J = sir_jacobian(S, I, R, c, beta, tau_R, tau_m)
%SIR_JACOBIAN  Jacobian of the SIR right-hand side at a given state.
%   Returns the 3-by-3 Jacobian matrix J_F = d(F_S,F_I,F_R)/d(S,I,R)
%   of the SIR model with demography at the state (S,I,R) and parameters
%   (c, beta, tau_R, tau_m).  Used by the forward sensitivity equations (FSE)
%   in Chapter 4 and the adjoint ODE in Chapter 6.
%
%   J = SIR_JACOBIAN(S, I, R, C, BETA, TAU_R, TAU_M) returns the 3x3 Jacobian.
%
%   Inputs:
%       S, I, R - state values (scalars, all >= 0)
%       c       - contact rate (positive scalar)
%       beta    - transmission probability (in (0,1))
%       tau_R   - mean infectious period in days (positive scalar)
%       tau_m   - mean residence time in days (positive scalar)
%
%   Outputs:
%       J - 3x3 Jacobian matrix (dF/d[S,I,R])
%           J(i,j) = d F_i / d x_j, where x = [S; I; R]
%
%   Example:
%       p  = sir_nominal();
%       J0 = sir_jacobian(p.S0, p.I0, p.R0_ic, p.c, p.beta, p.tau_R, p.tau_m);
%
%   Algorithm:
%       Exact analytic derivatives of eqs. (4.1)-(4.3).
%       N is the constant total population, held fixed (see eq. sirJacobian).
%
%   Reference: Arriola & Hyman, in preparation, eq. (4.16)-(4.17).
%   See also: SIR_MODEL, SIR_AUGMENTED

N     = S + I + R;
gamma_R = 1/tau_R;
nu_m    = 1/tau_m;
lam   = c*beta*I/N;    % force of infection

% dF_S/d[S,I,R]
% Constant-N convention, matching eq. (sirJacobian) in the book: N is held
% fixed at the nominal total population, so the birth term nu_m*N contributes
% no state derivative.  Column sums are therefore -nu_m, not zero.  The book's
% equation is canonical; do not reintroduce d(nu_m*N)/dx here.
dFS_dS = -c*beta*I/N - nu_m;
dFS_dI = -c*beta*S/N;
dFS_dR =  0;

dFI_dS =  c*beta*I/N;
dFI_dI =  c*beta*S/N - (gamma_R + nu_m);
dFI_dR =  0;

dFR_dS = 0;
dFR_dI = gamma_R;
dFR_dR = -nu_m;

J = [dFS_dS, dFS_dI, dFS_dR;
     dFI_dS, dFI_dI, dFI_dR;
     dFR_dS, dFR_dI, dFR_dR];
end
