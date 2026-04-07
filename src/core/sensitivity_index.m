function SI = sensitivity_index(q, q_nom, p, p_nom)
%SENSITIVITY_INDEX  Normalized sensitivity index S_p^q.
%   Computes the normalized sensitivity index of a quantity of interest Q
%   with respect to a parameter P, using either analytic derivatives or
%   finite-difference approximations.
%
%   The normalized SI is defined as (Chapter 2 of Arriola & Hyman):
%       S_p^q = (p/q) * (dq/dp)
%   Equivalently, via the discrete ratio form:
%       S_p^q ≈ (delta_q / q) / (delta_p / p)
%
%   SI = SENSITIVITY_INDEX(Q, Q_NOM, P, P_NOM) computes the SI using
%   the discrete-ratio form.  Q and P may be scalars or vectors of
%   the same length (one perturbation per entry).
%
%   Inputs:
%       q     - perturbed QOI value(s) (scalar or n-vector)
%       q_nom - nominal QOI value (scalar, must be nonzero)
%       p     - perturbed POI value(s) (scalar or n-vector, same size as q)
%       p_nom - nominal POI value (scalar, must be nonzero)
%
%   Outputs:
%       SI    - sensitivity index S_p^q (scalar or n-vector)
%
%   Notes:
%       For centered finite differences, pass q = [q(p+h), q(p-h)] and
%       p = [p_nom+h, p_nom-h]; the function returns a 2-vector and the
%       caller should average them (they will be nearly identical).
%
%       If q_nom is near zero, consider the regularized change index
%       instead (see Chapter 2).
%
%   Example:
%       % Verify S_tau^R0 = 1 analytically
%       p = sir_nominal();
%       R0     = @(tau) p.k * p.beta * tau;
%       h      = 1e-6 * p.tau;
%       SI_tau = sensitivity_index(R0(p.tau + h), R0(p.tau), ...
%                                  p.tau + h,     p.tau);
%       fprintf('S_tau^R0 = %.6f  (exact: 1.000000)\n', SI_tau);
%
%   See also: SENSITIVITY_JACOBIAN, SIR_NOMINAL

%   Reference: Arriola & Hyman, SIAM 2026, Definition 2.1 (eq. 2.1-2.3).

%% Input validation
validateattributes(q_nom, {'numeric'}, {'scalar','finite'}, ...
                   'sensitivity_index', 'q_nom');
validateattributes(p_nom, {'numeric'}, {'scalar','finite','nonzero'}, ...
                   'sensitivity_index', 'p_nom');
validateattributes(q, {'numeric'}, {'finite'}, 'sensitivity_index', 'q');
validateattributes(p, {'numeric'}, {'finite'}, 'sensitivity_index', 'p');

if numel(q) ~= numel(p)
    error('sensitivity_index:DimensionMismatch', ...
          'q and p must have the same number of elements.');
end

%% Warn if nominal QOI is near zero (regularization may be needed)
if abs(q_nom) < 1e-10 * max(1, abs(q_nom))
    warning('sensitivity_index:NearZeroQOI', ...
            ['q_nom = %.3e is near zero. ', ...
             'The normalized SI may be unreliable. ', ...
             'Consider the regularized change index (Chapter 2).'], q_nom);
end

%% Compute normalized SI: (delta_q / q_nom) / (delta_p / p_nom)
delta_q = q(:) - q_nom;
delta_p = p(:) - p_nom;

%% Guard against zero perturbation
zero_pert = (abs(delta_p) < eps * abs(p_nom));
if any(zero_pert)
    warning('sensitivity_index:ZeroPerturbation', ...
            '%d perturbation(s) are numerically zero; result set to NaN.', ...
            sum(zero_pert));
end

SI = zeros(size(delta_p));
SI(~zero_pert) = (delta_q(~zero_pert) ./ q_nom) ./ ...
                 (delta_p(~zero_pert) ./ p_nom);
SI(zero_pert) = NaN;
end
