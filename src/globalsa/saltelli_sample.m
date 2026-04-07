function [A, B] = saltelli_sample(N, m, lb, ub, use_qmc)
%SALTELLI_SAMPLE  Generate A and B sample matrices for Sobol analysis.
%   Builds the two base N-by-m sample matrices A and B needed by
%   SOBOL_JANSEN for variance-based global sensitivity analysis.
%   The total number of model evaluations is N*(m+2).
%
%   [A, B] = SALTELLI_SAMPLE(N, M, LB, UB) generates A and B using
%   Latin hypercube sampling (recommended; requires Statistics Toolbox)
%   or plain random sampling as a fallback.
%
%   [A, B] = SALTELLI_SAMPLE(N, M, LB, UB, USE_QMC) forces quasi-
%   Monte Carlo (Sobol sequence) if USE_QMC=true and Statistics Toolbox
%   is available.
%
%   Inputs:
%       N        - number of samples per matrix (integer >= 100 recommended)
%       m        - number of parameters (integer >= 1)
%       lb       - 1-by-m vector of lower bounds
%       ub       - 1-by-m vector of upper bounds
%       use_qmc  - logical: use quasi-Monte Carlo [default: false]
%
%   Outputs:
%       A - N-by-m sample matrix (scaled to [lb, ub])
%       B - N-by-m independent sample matrix (same distribution)
%
%   Notes:
%       - A and B must be statistically independent.
%       - Both matrices use the SAME sampling scheme for consistency.
%       - Set rng(seed) before calling for reproducibility.
%
%   Example:
%       rng(42);
%       [A, B] = saltelli_sample(1000, 4, zeros(1,4), ones(1,4));
%       % Use with sobol_jansen:
%       [S1, ST] = sobol_jansen(@my_model, A, B);
%
%   Reference: Saltelli, A. et al. (2002). Computer Physics Comm. 145:280.
%   See also: SOBOL_JANSEN, LHS_SAMPLE, MORRIS_SCREENING

if nargin < 5, use_qmc = false; end

%% --- Input validation --------------------------------------------------
validateattributes(N, {'numeric'}, {'scalar','integer','>=',10}, ...
                   'saltelli_sample','N');
validateattributes(m, {'numeric'}, {'scalar','integer','>=',1}, ...
                   'saltelli_sample','m');
lb = lb(:)';  ub = ub(:)';  % ensure row vectors
if numel(lb) ~= m || numel(ub) ~= m
    error('saltelli_sample:DimensionMismatch', ...
          'LB and UB must each have %d elements.', m);
end
if any(lb >= ub)
    error('saltelli_sample:InvalidBounds', ...
          'Each LB(j) must be strictly less than UB(j).');
end

%% --- Sampling in [0,1]^m ----------------------------------------------
has_stats_tb = license('test','Statistics_Toolbox');

if use_qmc && has_stats_tb
    % Quasi-Monte Carlo: Sobol sequence (best convergence)
    sob = sobolset(2*m, 'Skip', 1024, 'Leap', 0);
    U   = net(sob, N);   % N-by-2m in [0,1]
    U_A = U(:, 1:m);
    U_B = U(:, m+1:2*m);
elseif has_stats_tb
    % Latin hypercube (default: better coverage than random)
    U_A = lhsdesign(N, m);
    U_B = lhsdesign(N, m);
else
    % Plain random (Statistics Toolbox not available)
    warning('saltelli_sample:NoStatsTB', ...
            'Statistics Toolbox not found. Using plain random sampling.');
    U_A = rand(N, m);
    U_B = rand(N, m);
end

%% --- Scale to [lb, ub] ------------------------------------------------
range = ub - lb;   % 1-by-m
A = lb + U_A .* range;
B = lb + U_B .* range;
end
