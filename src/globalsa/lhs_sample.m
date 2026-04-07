function X = lhs_sample(N, m, lb, ub, options)
%LHS_SAMPLE  Latin hypercube sample in a rectangular parameter domain.
%   Generates an N-by-m Latin hypercube design scaled to the box
%   [lb(1),ub(1)] x ... x [lb(m),ub(m)].  Uses the Statistics Toolbox
%   LHSDESIGN when available; falls back to a manual stratified random
%   design otherwise.  Set rng(seed) before calling for reproducibility.
%
%   X = LHS_SAMPLE(N, M, LB, UB) returns an N-by-m sample matrix.
%   X = LHS_SAMPLE(N, M, LB, UB, OPTIONS) uses additional options.
%
%   Inputs:
%       N  - number of sample points (integer, >= 1)
%       m  - number of parameters (integer, >= 1)
%       lb - 1-by-m lower bound vector
%       ub - 1-by-m upper bound vector (must exceed lb entry-wise)
%       options - (optional) struct with fields:
%           .criterion : lhsdesign criterion ('maximin','correlation','none')
%                        [default: 'maximin']
%           .iterations: lhsdesign optimization iterations [default: 10]
%
%   Outputs:
%       X - N-by-m sample matrix; each row is one parameter vector
%
%   Notes:
%       For reproducible results, call rng(42) immediately before
%       lhs_sample.  The seed is not set internally to allow the caller
%       to control the random state.
%
%   Example:
%       rng(42);
%       p   = sir_nominal();
%       lb  = [0.3*p.k, 0.3*p.beta, 0.3*p.tau, 0.3*p.L];
%       ub  = [3.0*p.k, 3.0*p.beta, 3.0*p.tau, 3.0*p.L];
%       X   = lhs_sample(500, 4, lb, ub);
%       % X(i,:) is the i-th parameter combination to evaluate
%
%   Reference: McKay, M.D., Beckman, R.J. & Conover, W.J. (1979).
%   "A comparison of three methods for selecting values of input variables
%   in the analysis of output from a computer code."
%   Technometrics 21(2):239-245.
%
%   See also: SALTELLI_SAMPLE, SOBOL_JANSEN, COMPUTE_PRCC

%% --- Defaults ----------------------------------------------------------
if nargin < 5 || isempty(options), options = struct(); end
criterion  = getfield_default(options, 'criterion',  'maximin');
iterations = getfield_default(options, 'iterations', 10);

%% --- Input validation --------------------------------------------------
validateattributes(N, {'numeric'},{'scalar','integer','>=',1},'lhs_sample','N');
validateattributes(m, {'numeric'},{'scalar','integer','>=',1},'lhs_sample','m');
lb = lb(:)';  ub = ub(:)';
if numel(lb) ~= m || numel(ub) ~= m
    error('lhs_sample:DimensionMismatch', ...
          'LB and UB must each have %d elements.', m);
end
if any(lb >= ub)
    error('lhs_sample:InvalidBounds', ...
          'Each lb(j) must be strictly less than ub(j).');
end

%% --- Generate unit LHS in [0,1]^m -------------------------------------
if license('test', 'Statistics_Toolbox')
    U = lhsdesign(N, m, 'Criterion', criterion, 'Iterations', iterations);
else
    % Manual stratified random design (no toolbox required)
    warning('lhs_sample:NoStatsTB', ...
            ['Statistics Toolbox not available. ', ...
             'Using basic stratified random LHS (no maximin optimization).']);
    U = zeros(N, m);
    for j = 1:m
        perm    = randperm(N);
        U(:,j)  = (perm' - rand(N,1)) / N;
    end
end

%% --- Scale to [lb, ub] ------------------------------------------------
X = lb + U .* (ub - lb);
end

%% -----------------------------------------------------------------------
function val = getfield_default(s, field, default)
if isfield(s, field), val = s.(field); else, val = default; end
end
