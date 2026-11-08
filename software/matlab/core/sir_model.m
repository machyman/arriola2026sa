function dy = sir_model(t, y, c, beta, tau_R, tau_m)
%SIR_MODEL  Right-hand side of the SIR model with demography.
%   Implements the three-compartment SIR epidemic model used throughout
%   "Foundations of Sensitivity Analysis: From Local to Global Sensitivity"
%   (Arriola & Hyman, in preparation).  Designed to be passed directly to
%   MATLAB ODE solvers such as ODE45.
%
%   The model (equations 4.1-4.3 in the text):
%       dS/dt = nu_m*N - c*beta*S*I/N - nu_m*S
%       dI/dt = c*beta*S*I/N - (gamma_R + nu_m)*I
%       dR/dt = gamma_R*I - nu_m*R
%   where gamma_R = 1/tau_R, nu_m = 1/tau_m, N = S + I + R (constant).
%
%   DY = SIR_MODEL(T, Y, C, BETA, TAU_R, TAU_M) evaluates the RHS at time T
%   with state vector Y = [S; I; R] and parameters C, BETA, TAU_R, TAU_M.
%
%   Inputs:
%       t     - current time (scalar, days) -- unused but required by ODE45
%       y     - state vector [S; I; R], each non-negative (3x1)
%       c     - average contacts per person per day (positive scalar)
%       beta  - transmission probability per contact (in (0,1))
%       tau_R - mean infectious period in days (positive scalar)
%       tau_m - mean residence time in days (positive scalar)
%
%   Outputs:
%       dy    - derivative vector [dS/dt; dI/dt; dR/dt] (3x1)
%
%   Example:
%       p  = sir_nominal();
%       y0 = [p.S0; p.I0; p.R0_ic];
%       f  = @(t,y) sir_model(t, y, p.c, p.beta, p.tau_R, p.tau_m);
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
gamma_R = 1 / tau_R;    % recovery rate (day^-1)
nu_m    = 1 / tau_m;    % turnover rate (day^-1)

%% Force of infection
lambda = c * beta * I / N;

%% ODE right-hand side
dS = nu_m*N - lambda*S - nu_m*S;
dI = lambda*S - (gamma_R + nu_m)*I;
dR = gamma_R*I - nu_m*R;

dy = [dS; dI; dR];
end
