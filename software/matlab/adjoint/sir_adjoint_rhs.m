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
%              Book convention, eq. (adjODE): -d(lam)/dt = J_F^T*lam + grad_g,
%              so d(lam)/dt = -(J_F^T*lam + grad_g).  ode45 is called with
%              tspan = [T,0] and integrates this same equation backward in
%              time; running backward does not change the equation's sign.
%
%   Integration setup:
%       Terminal conditions: lam(T) = -h'(u(T)) = [0;0;0] for J = int I dt
%       (h = 0, no terminal cost)
%       Call:  ode45(@(t,lam) sir_adjoint_rhs(t,lam,...), [T,0], lam_T)
%
%   Example:
%       % See run_sir_adjoint.m for a complete working example.
%
%   Reference: Arriola & Hyman, in preparation, eq. (6.17)-(6.20).
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

%% --- Adjoint ODE, eq. (adjODE) -----------------------------------------
%   The book's boxed adjoint equation is
%       -d(lam)/dt = J_F^T * lam + grad_g,
%   hence in standard form
%       d(lam)/dt = -(J_F^T * lam + grad_g).
%   ode45 is called with tspan = [T, 0], which traverses t downward while
%   solving this same equation; the direction of travel is not a sign change.
%   Do not flip this sign to compensate for the direction of integration,
%   and do not compensate for it downstream in run_sir_adjoint.m: a pair of
%   offsetting sign changes can reproduce the right indices while matching
%   neither eq. (adjODE) nor eq. (sensfml_vec).
dlam = -(J' * lam + grad_g);
end
