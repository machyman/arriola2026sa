function [S1, ST, CI_S1, CI_ST] = sobol_jansen(f, A, B, n_boot, alpha)
%SOBOL_JANSEN  Sobol first-order and total-order indices via Jansen estimators.
%   Computes variance-based sensitivity indices for a scalar-output model f
%   using the Jansen (1999) estimators.  Optionally computes bootstrap
%   confidence intervals for both index types (Chapter 9, Arriola & Hyman).
%
%   Jansen estimators (eq. 9.9-9.10 in the text):
%       S1_i = 1 - (1/2N) * sum[(f(B) - f(A_B^i))^2] / Var(Y)
%       ST_i =     (1/2N) * sum[(f(A) - f(A_B^i))^2] / Var(Y)
%   where A_B^i is matrix A with column i replaced by column i of B.
%
%   [S1, ST] = SOBOL_JANSEN(F, A, B) computes indices without CI.
%   [S1, ST, CI_S1, CI_ST] = SOBOL_JANSEN(F, A, B, N_BOOT, ALPHA)
%   adds bootstrap confidence intervals.
%
%   Inputs:
%       f      - model function handle: f(x) -> scalar, x is 1-by-m row
%       A      - N-by-m base sample matrix (from SALTELLI_SAMPLE)
%       B      - N-by-m resampling matrix (from SALTELLI_SAMPLE)
%       n_boot - number of bootstrap replicates [default: 0 = no CI]
%       alpha  - CI significance level [default: 0.05 (95% CI)]
%
%   Outputs:
%       S1    - 1-by-m first-order Sobol indices
%       ST    - 1-by-m total-order Sobol indices
%       CI_S1 - 2-by-m confidence intervals for S1: [lower; upper]
%       CI_ST - 2-by-m confidence intervals for ST: [lower; upper]
%
%   Notes:
%       - Total evaluations: N*(m+2) (automatically handled by this function)
%       - If n_boot > 0, bootstrap resamples the N rows of A and B jointly
%       - S1 values outside [0,1] or ST values outside [0,1] indicate
%         numerical issues or strong parameter correlations
%
%   Example:
%       % Analytical test: Y = c1*X1 + c2*X2, X ~ U(0,1)
%       % Exact S1 = [c1^2, c2^2]/(c1^2+c2^2), ST = S1 (no interactions)
%       c = [2, 1];
%       f_test = @(x) c(1)*x(1) + c(2)*x(2);
%       rng(42);
%       p   = sir_nominal();
%       [A, B] = saltelli_sample(2000, 2, [0 0], [1 1]);
%       [S1, ST, CI_S1] = sobol_jansen(f_test, A, B, 200, 0.05);
%       % Expected: S1 ≈ [0.8, 0.2]
%
%   Algorithm:
%       Jansen (1999) Theorem 1; variance estimator pools fA and fB.
%       Bootstrap: resample row indices of (A, B) jointly B times;
%       95% CI from 2.5th and 97.5th percentiles.
%
%   Reference: Jansen, M.J.W. (1999). "Analysis of variance designs for
%   model output." Computer Physics Communications 117:35-43.
%   Saltelli, A. et al. (2002). "Making best use of model evaluations."
%   Computer Physics Communications 145:280-297.
%   See also: SALTELLI_SAMPLE, LHS_SAMPLE, MORRIS_SCREENING

%% --- Defaults ----------------------------------------------------------
if nargin < 4 || isempty(n_boot), n_boot = 0;    end
if nargin < 5 || isempty(alpha),  alpha  = 0.05; end

%% --- Input validation --------------------------------------------------
validateattributes(A, {'numeric'}, {'2d','nonempty','finite'}, ...
                   'sobol_jansen', 'A');
validateattributes(B, {'numeric'}, {'2d','nonempty','finite'}, ...
                   'sobol_jansen', 'B');
if ~isequal(size(A), size(B))
    error('sobol_jansen:DimensionMismatch', ...
          'A and B must have the same dimensions.');
end
if ~isa(f, 'function_handle')
    error('sobol_jansen:InvalidModel', 'F must be a function handle.');
end

[N, m] = size(A);

%% --- Evaluate model on A and B -----------------------------------------
fA = zeros(N, 1);
fB = zeros(N, 1);
for i = 1:N
    fA(i) = f(A(i,:));
    fB(i) = f(B(i,:));
end

%% --- Variance estimator (pooled) ----------------------------------------
D_hat = var([fA; fB]);    % pooled variance estimate
if D_hat < eps
    warning('sobol_jansen:ZeroVariance', ...
            'Model output has near-zero variance. Indices set to NaN.');
    S1 = NaN(1, m); ST = NaN(1, m);
    CI_S1 = NaN(2, m); CI_ST = NaN(2, m);
    return;
end

%% --- Evaluate AB^(i) matrices and compute indices ----------------------
S1 = zeros(1, m);
ST = zeros(1, m);

for i = 1:m
    % Build A_B^(i): A with column i replaced by B's column i
    AB_i = A;
    AB_i(:, i) = B(:, i);
    
    % Evaluate model on A_B^(i)
    f_AB_i = zeros(N, 1);
    for j = 1:N
        f_AB_i(j) = f(AB_i(j,:));
    end
    
    % Jansen estimators
    S1(i) = 1 - mean((fB - f_AB_i).^2) / (2 * D_hat);
    ST(i) =     mean((fA - f_AB_i).^2) / (2 * D_hat);
end

%% --- Bootstrap confidence intervals ------------------------------------
if n_boot > 0
    S1_boot = zeros(n_boot, m);
    ST_boot = zeros(n_boot, m);
    
    for b = 1:n_boot
        % Resample row indices jointly (preserves joint distribution)
        idx = randi(N, N, 1);
        A_b = A(idx, :);
        B_b = B(idx, :);
        % Recursive call without CI to avoid infinite recursion
        [S1_boot(b,:), ST_boot(b,:)] = sobol_jansen(f, A_b, B_b);
    end
    
    probs = [alpha/2, 1 - alpha/2] * 100;
    CI_S1 = prctile(S1_boot, probs, 1)';   % 2-by-m
    CI_ST = prctile(ST_boot, probs, 1)';
else
    CI_S1 = NaN(2, m);
    CI_ST = NaN(2, m);
end
end
