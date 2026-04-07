function dy = sir_model(t, y, k, beta, tau, L)
%SIR_MODEL  Right-hand side of the SIR model with demography.
%   Implements the three-compartment SIR epidemic model used throughout
%   "Foundations of Sensitivity Analysis: Theory, Computation, and Applications"
%   (Arriola & Hyman, SIAM 2026).  Designed to be passed directly to
%   MATLAB ODE solvers such as ODE45.
%
%   The model (equations 4.1-4.3 in the text):
%       dS/dt = mu*N - k*beta*S*I/N - mu*S
%       dI/dt = k*beta*S*I/N - (gamma + mu)*I
%       dR/dt = gamma*I - mu*R
%   where gamma = 1/tau, mu = 1/L, N = S + I + R (constant).
%
%   DY = SIR_MODEL(T, Y, K, BETA, TAU, L) evaluates the RHS at time T
%   with state vector Y = [S; I; R] and parameters K, BETA, TAU, L.
%
%   Inputs:
%       t    - current time (scalar, days) -- unused but required by ODE45
%       y    - state vector [S; I; R], each non-negative (3x1)
%       k    - average contacts per person per day (positive scalar)
%       beta - transmission probability per contact (in (0,1))
%       tau  - mean infectious period in days (positive scalar)
%       L    - mean lifespan in days (positive scalar)
%
%   Outputs:
%       dy   - derivative vector [dS/dt; dI/dt; dR/dt] (3x1)
%
%   Example:
%       p  = sir_nominal();
%       y0 = [p.S0; p.I0; p.R0_ic];
%       f  = @(t,y) sir_model(t, y, p.k, p.beta, p.tau, p.L);
%       [t, Y] = ode45(f, [0 p.T], y0);
%       plot(t, Y(:,2));  xlabel('Days'); ylabel('I(t)');
%
%   Algorithm:
%       Direct evaluation of the three ODE right-hand sides.
%       Computational cost: O(1) per call.
%
%   Reference: Kermack & McKendrick (1927); Anderson & May (1991).
%   See also: SIR_NOMINAL, RUN_SIR_EXAMPLE, SIR_AUGMENTED

%% Input column-vector guard
if isrow(y), y = y(:); end

%% Unpack state
S = y(1);
I = y(2);
R = y(3);

%% Total population (conserved)
N = S + I + R;

%% Derived parameters
gamma = 1 / tau;    % recovery rate (day^-1)
mu    = 1 / L;      % background mortality rate (day^-1)

%% Force of infection
lambda = k * beta * I / N;

%% ODE right-hand side
dS = mu*N - lambda*S - mu*S;
dI = lambda*S - (gamma + mu)*I;
dR = gamma*I - mu*R;

dy = [dS; dI; dR];
end
