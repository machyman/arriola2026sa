function dy = sir_augmented(t, y, c, beta, tau_R, tau_m)
%SIR_AUGMENTED  Augmented ODE: SIR model + 12 forward sensitivity equations.
%   Implements the 15-equation augmented system for computing all four
%   time-dependent sensitivity indices simultaneously, as described in
%   Chapter 4 of Arriola & Hyman (eq. 4.13-4.15).
%
%   The augmented state vector is:
%       y = [S; I; R; w_S1; w_I1; w_R1; ... ; w_S4; w_I4; w_R4]
%   where w_xj(t) = d x(t) / d p_j and p = [c, beta, tau_R, tau_m].
%
%   DY = SIR_AUGMENTED(T, Y, C, BETA, TAU_R, TAU_M) returns the 15-vector
%   of derivatives at state Y and parameters C, BETA, TAU_R, TAU_M.
%   Compatible with ODE45.
%
%   Inputs:
%       t         - current time (scalar, days) -- required by ODE45
%       y         - augmented state vector (15x1):
%                     y(1:3)   = [S; I; R]
%                     y(4:6)   = [w_S1; w_I1; w_R1]  (sens. to c)
%                     y(7:9)   = [w_S2; w_I2; w_R2]  (sens. to beta)
%                     y(10:12) = [w_S3; w_I3; w_R3]  (sens. to tau_R)
%                     y(13:15) = [w_S4; w_I4; w_R4]  (sens. to tau_m)
%       c, beta, tau_R, tau_m - scalar parameters
%
%   Outputs:
%       dy - 15x1 derivative vector (same layout as y)
%
%   Initial conditions:
%       y0 = [S0; I0; R0; zeros(12,1)]
%       (Sensitivities start at zero because initial conditions are
%        fixed and do not depend on the POIs.)
%
%   Example:
%       p    = sir_nominal();
%       y0   = [p.S0; p.I0; p.R0_ic; zeros(12,1)];
%       f    = @(t,y) sir_augmented(t,y, p.c,p.beta,p.tau_R,p.tau_m);
%       opts = odeset('RelTol',1e-8,'AbsTol',1e-10,'MaxStep',0.5);
%       [t,Y] = ode45(f, [0 p.T], y0, opts);
%       % SI_c(I)(t) = (p.c / Y(:,2)) .* Y(:,5)  (normalized)
%
%   Reference: Arriola & Hyman, in preparation, eq. (4.13)-(4.17).
%   See also: SIR_MODEL, SIR_JACOBIAN, COMPUTE_TIME_SI

if isrow(y), y = y(:); end
assert(length(y) == 15, 'sir_augmented: state y must be 15x1');

%% --- Unpack state -------------------------------------------------------
S = y(1); I = y(2); R = y(3);
N = S + I + R;

%% --- Jacobian at current state ------------------------------------------
J = sir_jacobian(S, I, R, c, beta, tau_R, tau_m);

%% --- FSE right-hand side vectors dF/dp_j --------------------------------
% p1 = c:   F_S = nu_m*N - c*beta*SI/N - nu_m*S
%            dF_S/dc = -beta*S*I/N
%            dF_I/dc = +beta*S*I/N
%            dF_R/dc = 0
dFdp1 = [-beta*S*I/N; +beta*S*I/N; 0];

% p2 = beta: symmetric to c
%            dF_S/dbeta = -c*S*I/N
%            dF_I/dbeta = +c*S*I/N
%            dF_R/dbeta = 0
dFdp2 = [-c*S*I/N; +c*S*I/N; 0];

% p3 = tau_R: gamma_R = 1/tau_R, so dF/dtau_R via chain rule: dgamma_R/dtau_R = -1/tau_R^2
%            dF_S/dtau_R = 0
%            dF_I/dtau_R = -(-1/tau_R^2)*I = I/tau_R^2 = gamma_R^2 * I
%            dF_R/dtau_R = (1/tau_R^2)*I = gamma_R^2*I (from dF_R/dgamma_R = I, dgamma_R/dtau_R = -1/tau_R^2)
%  Careful sign: F_I = ...- (gamma_R+nu_m)*I, so dF_I/dgamma_R = -I
%                dF_I/dtau_R = dF_I/dgamma_R * dgamma_R/dtau_R = (-I)*(-1/tau_R^2) = I/tau_R^2
gamma_R = 1/tau_R;
dFdp3 = [0; I/tau_R^2; -I/tau_R^2];

% p4 = tau_m: nu_m = 1/tau_m, so dnu_m/dtau_m = -1/tau_m^2
%            dF_S/dtau_m = dF_S/dnu_m * dnu_m/dtau_m = (N-S)*(-1/tau_m^2)  [from dF_S/dnu_m = N-S]
%            Wait: F_S = nu_m*N - c*beta*S*I/N - nu_m*S = nu_m*(N-S) - force
%            dF_S/dnu_m = N - S;   dF_S/dtau_m = (N-S)*(-1/tau_m^2)
%            F_I = force - (gamma_R+nu_m)*I;  dF_I/dnu_m = -I;  dF_I/dtau_m = I/tau_m^2
%            F_R = gamma_R*I - nu_m*R;        dF_R/dnu_m = -R;  dF_R/dtau_m = R/tau_m^2
nu_m    = 1/tau_m;
dFdp4 = [(-(N-S)/tau_m^2); (I/tau_m^2); (R/tau_m^2)];

%% --- Compute FSE: dw_j/dt = J * w_j + dF/dp_j --------------------------
dy = zeros(15, 1);

% Original SIR ODE (eqs. 4.1-4.3)
dy(1:3) = sir_model(t, y(1:3), c, beta, tau_R, tau_m);

% FSE for each POI j = 1..4
rhs_vec = {dFdp1, dFdp2, dFdp3, dFdp4};
for j = 1:4
    idx    = 3 + (j-1)*3 + (1:3);
    w_j    = y(idx);
    dy(idx) = J * w_j + rhs_vec{j};
end
end
