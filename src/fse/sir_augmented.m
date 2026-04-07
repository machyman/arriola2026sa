function dy = sir_augmented(t, y, k, beta, tau, L)
%SIR_AUGMENTED  Augmented ODE: SIR model + 12 forward sensitivity equations.
%   Implements the 15-equation augmented system for computing all four
%   time-dependent sensitivity indices simultaneously, as described in
%   Chapter 4 of Arriola & Hyman (eq. 4.13-4.15).
%
%   The augmented state vector is:
%       y = [S; I; R; w_S1; w_I1; w_R1; ... ; w_S4; w_I4; w_R4]
%   where w_xj(t) = d x(t) / d p_j and p = [k, beta, tau, L].
%
%   DY = SIR_AUGMENTED(T, Y, K, BETA, TAU, L) returns the 15-vector
%   of derivatives at state Y and parameters K, BETA, TAU, L.
%   Compatible with ODE45.
%
%   Inputs:
%       t         - current time (scalar, days) -- required by ODE45
%       y         - augmented state vector (15x1):
%                     y(1:3)   = [S; I; R]
%                     y(4:6)   = [w_S1; w_I1; w_R1]  (sens. to k)
%                     y(7:9)   = [w_S2; w_I2; w_R2]  (sens. to beta)
%                     y(10:12) = [w_S3; w_I3; w_R3]  (sens. to tau)
%                     y(13:15) = [w_S4; w_I4; w_R4]  (sens. to L)
%       k, beta, tau, L - scalar parameters
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
%       f    = @(t,y) sir_augmented(t,y, p.k,p.beta,p.tau,p.L);
%       opts = odeset('RelTol',1e-8,'AbsTol',1e-10,'MaxStep',0.5);
%       [t,Y] = ode45(f, [0 p.T], y0, opts);
%       % SI_k(I)(t) = (p.k / Y(:,2)) .* Y(:,5)  (normalized)
%
%   Reference: Arriola & Hyman, SIAM 2026, eq. (4.13)-(4.17).
%   See also: SIR_MODEL, SIR_JACOBIAN, COMPUTE_TIME_SI

if isrow(y), y = y(:); end
assert(length(y) == 15, 'sir_augmented: state y must be 15x1');

%% --- Unpack state -------------------------------------------------------
S = y(1); I = y(2); R = y(3);
N = S + I + R;

%% --- Jacobian at current state ------------------------------------------
J = sir_jacobian(S, I, R, k, beta, tau, L);

%% --- FSE right-hand side vectors dF/dp_j --------------------------------
% p1 = k:   F_S = mu*N - k*beta*SI/N - mu*S
%            dF_S/dk = -beta*S*I/N
%            dF_I/dk = +beta*S*I/N
%            dF_R/dk = 0
dFdp1 = [-beta*S*I/N; +beta*S*I/N; 0];

% p2 = beta: symmetric to k
%            dF_S/dbeta = -k*S*I/N
%            dF_I/dbeta = +k*S*I/N
%            dF_R/dbeta = 0
dFdp2 = [-k*S*I/N; +k*S*I/N; 0];

% p3 = tau: gamma = 1/tau, so dF/dtau via chain rule: dgamma/dtau = -1/tau^2
%            dF_S/dtau = 0
%            dF_I/dtau = -(-1/tau^2)*I = I/tau^2 = gamma^2 * I
%            dF_R/dtau = (1/tau^2)*I = gamma^2*I (from dF_R/dgamma = I, dgamma/dtau = -1/tau^2)
%  Careful sign: F_I = ...- (gamma+mu)*I, so dF_I/dgamma = -I
%                dF_I/dtau = dF_I/dgamma * dgamma/dtau = (-I)*(-1/tau^2) = I/tau^2
gamma = 1/tau;
dFdp3 = [0; I/tau^2; -I/tau^2];

% p4 = L: mu = 1/L, so dmu/dL = -1/L^2
%            dF_S/dL = dF_S/dmu * dmu/dL = (N-S)*(-1/L^2)  [from dF_S/dmu = N-S]
%            Wait: F_S = mu*N - k*beta*S*I/N - mu*S = mu*(N-S) - force
%            dF_S/dmu = N - S;   dF_S/dL = (N-S)*(-1/L^2)
%            F_I = force - (gamma+mu)*I;  dF_I/dmu = -I;  dF_I/dL = I/L^2
%            F_R = gamma*I - mu*R;        dF_R/dmu = -R;  dF_R/dL = R/L^2
mu    = 1/L;
dFdp4 = [(-(N-S)/L^2); (I/L^2); (R/L^2)];

%% --- Compute FSE: dw_j/dt = J * w_j + dF/dp_j --------------------------
dy = zeros(15, 1);

% Original SIR ODE (eqs. 4.1-4.3)
dy(1:3) = sir_model(t, y(1:3), k, beta, tau, L);

% FSE for each POI j = 1..4
rhs_vec = {dFdp1, dFdp2, dFdp3, dFdp4};
for j = 1:4
    idx    = 3 + (j-1)*3 + (1:3);
    w_j    = y(idx);
    dy(idx) = J * w_j + rhs_vec{j};
end
end
