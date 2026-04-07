function [S, info] = sensitivity_jacobian(model, p_nom, n_q, options)
%SENSITIVITY_JACOBIAN  Normalized sensitivity Jacobian via centered differences.
%   Computes the n_q-by-n_p matrix S where S(k,j) = S_{p_j}^{q_k} is the
%   normalized sensitivity index of the k-th QOI with respect to the j-th
%   POI.  Uses second-order centered differences with automatic step-size
%   selection (Chapter 3 of Arriola & Hyman).
%
%   [S, INFO] = SENSITIVITY_JACOBIAN(MODEL, P_NOM, N_Q) computes the
%   full n_q-by-n_p sensitivity Jacobian at the nominal parameter vector
%   P_NOM.  MODEL must be a function handle accepting an n_p-column vector
%   and returning an n_q-column vector.
%
%   [...] = SENSITIVITY_JACOBIAN(MODEL, P_NOM, N_Q, OPTIONS) uses
%   user-supplied options.
%
%   Inputs:
%       model  - function handle @(p) -> n_q-vector of QOIs
%       p_nom  - n_p-vector of nominal parameter values (all nonzero)
%       n_q    - number of QOIs (positive integer)
%       options - (optional) struct with fields:
%           .h_scale : step-size multiplier [default: 6e-6]
%                      h_j = h_scale * |p_nom(j)|
%           .h_min   : minimum absolute step size [default: 1e-12]
%           .verbose : print progress if true [default: false]
%
%   Outputs:
%       S    - n_q-by-n_p matrix of normalized sensitivity indices
%       info - struct with diagnostic fields:
%           .h         : n_p-vector of step sizes used
%           .q_nom     : n_q-vector of nominal QOI values
%           .n_evals   : total number of model evaluations (= 2*n_p + 1)
%           .err_est   : n_p-vector of estimated FD error indicators
%
%   Example:
%       p   = sir_nominal();
%       R0  = @(pv) p.k * pv(1) * pv(3);   % QOI = R0 = k*beta*tau
%       pv0 = [p.beta; p.tau];               % two POIs
%       [S, info] = sensitivity_jacobian(R0, pv0, 1);
%       % Expected: S = [1, 1]  (both SI_beta and SI_tau = 1 for R0)
%
%   Algorithm:
%       Centered difference: dq/dp_j ≈ [q(p+h*e_j) - q(p-h*e_j)] / (2h).
%       Step size: h_j = h_scale * max(|p_nom(j)|, h_min).
%       Convergence check: compare against forward difference; flag if
%       ratio deviates from 1 by more than 5%.
%       Cost: 2*n_p + 1 model evaluations.
%
%   Reference: Arriola & Hyman, SIAM 2026, Ch.3.  Step-size formula from
%   eq. (3.8): h* ≈ eps_mach^(1/3) * |p*| ≈ 6e-6 * |p*|.
%
%   See also: SENSITIVITY_INDEX, TORNADO_PLOT, SIR_NOMINAL

%% --- Default options ---------------------------------------------------
if nargin < 4 || isempty(options)
    options = struct();
end
h_scale = getfield_default(options, 'h_scale', 6e-6);
h_min   = getfield_default(options, 'h_min',   1e-12);
verbose = getfield_default(options, 'verbose', false);

%% --- Input validation --------------------------------------------------
validateattributes(p_nom, {'numeric'}, {'vector','finite','nonzero'}, ...
                   'sensitivity_jacobian', 'p_nom');
validateattributes(n_q,   {'numeric'}, {'scalar','integer','positive'}, ...
                   'sensitivity_jacobian', 'n_q');
if ~isa(model, 'function_handle')
    error('sensitivity_jacobian:InvalidModel', ...
          'MODEL must be a function handle.');
end

p_nom  = p_nom(:);   % ensure column vector
n_p    = length(p_nom);

%% --- Baseline evaluation -----------------------------------------------
q_nom = model(p_nom);
q_nom = q_nom(:);
if length(q_nom) ~= n_q
    error('sensitivity_jacobian:QOIMismatch', ...
          'MODEL returned %d values but N_Q = %d.', length(q_nom), n_q);
end
n_evals = 1;

%% --- Step sizes --------------------------------------------------------
h = h_scale * max(abs(p_nom), h_min / h_scale);  % n_p-vector

%% --- Preallocate outputs -----------------------------------------------
S       = zeros(n_q, n_p);
err_est = zeros(1, n_p);

%% --- Centered difference loop ------------------------------------------
for j = 1:n_p
    if verbose
        fprintf('  Parameter %d/%d (p_nom = %.4g, h = %.2e)\n', ...
                j, n_p, p_nom(j), h(j));
    end

    % Perturbation vectors
    p_plus  = p_nom;  p_plus(j)  = p_nom(j) + h(j);
    p_minus = p_nom;  p_minus(j) = p_nom(j) - h(j);

    q_plus  = model(p_plus)(:);
    q_minus = model(p_minus)(:);
    n_evals = n_evals + 2;

    % Centered difference derivative
    dqdpj = (q_plus - q_minus) / (2 * h(j));

    % Normalize: S(k,j) = (p_nom(j) / q_nom(k)) * dqdpj(k)
    for k = 1:n_q
        if abs(q_nom(k)) > eps
            S(k,j) = (p_nom(j) / q_nom(k)) * dqdpj(k);
        else
            S(k,j) = NaN;   % QOI is zero at nominal; SI undefined
        end
    end

    % Error indicator: |q_plus - 2*q_nom + q_minus| / |q_plus - q_minus|
    % A ratio near 0 = good centered FD; ratio > 0.1 = step-size warning
    num = norm(q_plus - 2*q_nom + q_minus);
    den = norm(q_plus - q_minus);
    if den > eps
        err_est(j) = num / den;
        if err_est(j) > 0.1
            warning('sensitivity_jacobian:StepSizeWarning', ...
                ['Parameter %d: error indicator = %.3f > 0.1. ', ...
                 'Consider adjusting h_scale.'], j, err_est(j));
        end
    end
end

%% --- Package diagnostics -----------------------------------------------
info.h       = h;
info.q_nom   = q_nom;
info.n_evals = n_evals;
info.err_est = err_est;
end

%% -----------------------------------------------------------------------
function val = getfield_default(s, field, default)
%GETFIELD_DEFAULT  Return s.field if it exists, otherwise default.
if isfield(s, field)
    val = s.(field);
else
    val = default;
end
end
