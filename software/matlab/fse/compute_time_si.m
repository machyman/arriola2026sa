function [SI_t, t, Y_state] = compute_time_si(p, qoi_idx, t_span, ode_opts)
%COMPUTE_TIME_SI  Time-dependent sensitivity indices for the SIR model.
%   Solves the 15-equation augmented ODE (SIR + FSE) and returns the
%   four normalized sensitivity index curves SI_{p_j}^{q}(t) for the
%   chosen QOI, where p = [k, beta, tau, L].
%
%   [SI_T, T, Y_STATE] = COMPUTE_TIME_SI(P) uses all defaults.
%   [SI_T, T, Y_STATE] = COMPUTE_TIME_SI(P, QOI_IDX) specifies the QOI.
%   [SI_T, T, Y_STATE] = COMPUTE_TIME_SI(P, QOI_IDX, T_SPAN, ODE_OPTS)
%
%   Inputs:
%       p        - parameter struct from SIR_NOMINAL (or with same fields)
%       qoi_idx  - index of the QOI compartment: 1=S, 2=I (default), 3=R
%       t_span   - [t0, tf] integration interval [default: [0, p.T]]
%       ode_opts - odeset options struct [default: RelTol=1e-8, AbsTol=1e-10]
%
%   Outputs:
%       SI_t    - n_t-by-4 matrix: SI_t(i,j) = S_{p_j}^{q}(t_i)
%                 Columns: [SI_k, SI_beta, SI_tau, SI_L]
%       t       - n_t-vector of output times
%       Y_state - n_t-by-3 matrix of [S(t), I(t), R(t)]
%
%   Notes:
%       At times when q(t) is near zero (early epidemic for I), the
%       normalized SI is set to NaN rather than returning Inf/large values.
%
%   Example:
%       p = sir_nominal();
%       [SI_t, t, Y] = compute_time_si(p, 2);   % QOI = I(t)
%       plot(t, SI_t);
%       legend({'$S_{k}^{I}$','$S_{\beta}^{I}$','$S_{\tau}^{I}$','$S_L^I$'}, ...
%              'Interpreter','latex');
%
%   See also: SIR_AUGMENTED, PLOT_TIME_SI, SIR_NOMINAL

%% --- Defaults ----------------------------------------------------------
if nargin < 2 || isempty(qoi_idx),  qoi_idx  = 2; end   % I(t) default
if nargin < 3 || isempty(t_span),   t_span   = [0, p.T]; end
if nargin < 4 || isempty(ode_opts)
    ode_opts = odeset('RelTol',1e-8,'AbsTol',1e-10,'MaxStep',0.5);
end

validateattributes(qoi_idx, {'numeric'}, {'scalar','integer','>=',1,'<=',3}, ...
                   'compute_time_si', 'qoi_idx');

%% --- Solve augmented ODE -----------------------------------------------
y0  = [p.S0; p.I0; p.R0_ic; zeros(12,1)];
f   = @(t,y) sir_augmented(t, y, p.k, p.beta, p.tau, p.L);
[t, Y] = ode45(f, t_span, y0, ode_opts);

%% --- Extract state and sensitivity vectors -----------------------------
Y_state = Y(:, 1:3);           % [S, I, R]  (n_t x 3)
q       = Y(:, qoi_idx);        % QOI time series (n_t x 1)

% POI nominal values
p_nom = [p.k, p.beta, p.tau, p.L];

% Sensitivity vectors: w_{xj}(t) = dq/dp_j at qoi component
% qoi_idx selects which compartment sensitivity we extract:
%   SI_j(t) = (p_j / q(t)) * w_{qoi}_{j}(t)
SI_t = NaN(length(t), 4);
for j = 1:4
    aug_idx    = 3 + (j-1)*3 + qoi_idx;   % index in augmented state
    w_j        = Y(:, aug_idx);            % dq/dp_j(t)
    near_zero  = abs(q) < 1e-6 * max(abs(q));
    SI_j       = zeros(size(q));
    SI_j(~near_zero) = (p_nom(j) ./ q(~near_zero)) .* w_j(~near_zero);
    SI_j(near_zero)  = NaN;
    SI_t(:, j) = SI_j;
end
end
