function dlam = sir_adjoint_rhs(t, lam, S_fn, I_fn, R_fn, k, beta, tau, L)
%SIR_ADJOINT_RHS  Right-hand side of the SIR adjoint ODE.
%   Implements the adjoint equations derived in Chapter 6 of
%   Arriola & Hyman (eq. 6.17-6.19) for the response functional J = int I dt.
%   Must be integrated BACKWARD in time from t=T to t=0.
%
%   The adjoint ODE is:
%       -d lambda_S/dt = J_F^T(t) * lambda(t) - grad_u g(t)
%   where J_F is the SIR Jacobian and g = (0, I, 0)^T (integrand for J=int I dt).
%
%   DLAM = SIR_ADJOINT_RHS(T, LAM, S_FN, I_FN, R_FN, K, BETA, TAU, L)
%   returns the adjoint derivative vector at time T.
%
%   Inputs:
%       t              - current time (scalar)
%       lam            - adjoint vector [lambda_S; lambda_I; lambda_R] (3x1)
%       S_fn, I_fn, R_fn - interpolating functions for S(t), I(t), R(t)
%                          (from griddedInterpolant or similar)
%       k, beta, tau, L - scalar parameters
%
%   Outputs:
%       dlam - time derivative of adjoint (3x1)
%              Note: ODE45 is called with flipped time (tspan=[T,0]),
%              so the sign convention is: dlam = J_F^T * lam - grad_g.
%
%   Integration setup:
%       Terminal conditions: lam(T) = -h'(u(T)) = [0;0;0] for J = int I dt
%       (h = 0, no terminal cost)
%       Call:  ode45(@(t,lam) sir_adjoint_rhs(t,lam,...), [T,0], lam_T)
%
%   Example:
%       % See run_sir_adjoint.m for a complete working example.
%
%   Reference: Arriola & Hyman, SIAM 2026, eq. (6.17)-(6.20).
%   See also: RUN_SIR_ADJOINT, SIR_JACOBIAN, SIR_AUGMENTED

if isrow(lam), lam = lam(:); end

%% --- Interpolate forward solution at current time ----------------------
S = S_fn(t);
I = I_fn(t);
R = R_fn(t);

%% --- Jacobian at current state -----------------------------------------
J = sir_jacobian(S, I, R, k, beta, tau, L);

%% --- Running cost gradient: g = I, so grad_u g = [0; 1; 0] ------------
grad_g = [0; 1; 0];

%% --- Adjoint ODE (backward form): d(lam)/dt = J_F^T * lam - grad_g ---
%   Written as d/dt so that ode45 with tspan=[T,0] integrates correctly.
%   The sign on the adjoint equation in the text is:
%       -d(lam)/dt = J_F^T * lam - grad_g
%   which in standard form (dy/dt = ...) becomes:
%       d(lam)/dt = -(J_F^T * lam - grad_g) = grad_g - J_F^T * lam
%   BUT ode45 is called with tspan = [T, 0] (backward), so we pass
%   the RHS WITHOUT the sign flip; ode45 handles the negative time step.
%   This matches: -dlam/dt = J^T lam - grad_g  =>  dlam/dt = grad_g - J^T lam
dlam = grad_g - J' * lam;
end
