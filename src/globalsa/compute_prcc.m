function [rho, pval] = compute_prcc(X, Y, param_names)
%COMPUTE_PRCC  Partial Rank Correlation Coefficients (PRCC).
%   Computes PRCC between each column of X and the output vector Y,
%   controlling for all other columns.  PRCC is the standard global
%   sensitivity measure for monotone models (Chapter 9, Arriola & Hyman).
%
%   PRCC is computed by:
%     1. Rank-transforming X and Y (converting to uniform marginals).
%     2. Computing partial correlations of each X_j with Y given all
%        other X columns.
%
%   [RHO, PVAL] = COMPUTE_PRCC(X, Y) returns PRCC values and p-values.
%   [RHO, PVAL] = COMPUTE_PRCC(X, Y, PARAM_NAMES) also prints a table.
%
%   Inputs:
%       X           - N-by-m matrix of parameter samples (from LHS_SAMPLE)
%       Y           - N-by-1 vector of model outputs
%       param_names - (optional) m-element cell array of parameter names
%                     for display.  If omitted, prints p1...pm.
%
%   Outputs:
%       rho  - 1-by-m vector of PRCC values (in [-1, 1])
%       pval - 1-by-m vector of p-values for the null hypothesis rho=0
%
%   Notes:
%       - Requires Statistics Toolbox (partialcorr function).
%         Fallback: computes Spearman rank correlation (not partial).
%       - PRCC values near ±1 indicate strong monotone influence.
%       - |PRCC| > 0.5 with p < 0.05 is typically considered significant.
%       - Before using PRCC, verify monotonicity assumption with a
%         scatter matrix: plotmatrix(X, Y).
%
%   Example:
%       p   = sir_nominal();
%       lb  = 0.5 * [p.k, p.beta, p.tau, p.L];
%       ub  = 2.0 * [p.k, p.beta, p.tau, p.L];
%       rng(42);
%       X   = lhs_sample(500, 4, lb, ub);
%       Y   = arrayfun(@(i) sir_R0(X(i,:)), 1:500)';
%       [rho, pval] = compute_prcc(X, Y, {'k','beta','tau','L'});
%
%   Reference: Marino, S. et al. (2008). "A methodology for performing
%   global uncertainty and sensitivity analysis in systems biology."
%   Journal of Theoretical Biology 254(1):178-196.
%   See also: LHS_SAMPLE, SOBOL_JANSEN, SALTELLI_SAMPLE

%% --- Input validation --------------------------------------------------
validateattributes(X, {'numeric'}, {'2d','nonempty','finite'}, ...
                   'compute_prcc', 'X');
validateattributes(Y, {'numeric'}, {'vector','nonempty','finite'}, ...
                   'compute_prcc', 'Y');
Y = Y(:);
[N, m] = size(X);
if length(Y) ~= N
    error('compute_prcc:DimensionMismatch', ...
          'X has %d rows but Y has %d elements.', N, length(Y));
end
if nargin < 3 || isempty(param_names)
    param_names = arrayfun(@(j) sprintf('p%d',j), 1:m, 'UniformOutput',false);
    do_print = false;
else
    do_print = true;
end

%% --- Rank transform (ties handled by average rank) ---------------------
X_rank = zeros(N, m);
for j = 1:m
    X_rank(:,j) = tiedrank(X(:,j));
end
Y_rank = tiedrank(Y);

%% --- Partial correlation using Statistics Toolbox ----------------------
if license('test', 'Statistics_Toolbox')
    % partialcorr computes partial Pearson correlations on rank-transformed data
    % = PRCC by definition
    Z = [X_rank, Y_rank];
    [rho_mat, pval_mat] = partialcorr(Z, 'Type', 'Pearson');
    % Last row/column of rho_mat gives correlation of Y with each X_j
    rho  = rho_mat(end, 1:m);
    pval = pval_mat(end, 1:m);
else
    % Fallback: Spearman rank correlation (not partial)
    warning('compute_prcc:NoStatsTB', ...
            ['Statistics Toolbox not available. ', ...
             'Computing Spearman rank correlation instead of PRCC. ', ...
             'Results are not partial correlations.']);
    rho  = zeros(1, m);
    pval = zeros(1, m);
    for j = 1:m
        [rho(j), pval(j)] = corr(X_rank(:,j), Y_rank, 'Type','Pearson');
    end
end

%% --- Print table if param_names provided ------------------------------
if do_print
    fprintf('\nPRCC Results:\n');
    fprintf('  %-12s %8s %8s %10s\n', 'Parameter', 'PRCC', 'p-value', 'Signif.');
    fprintf('  %s\n', repmat('-',1,44));
    for j = 1:m
        sig = '';
        if pval(j) < 0.001, sig = '***';
        elseif pval(j) < 0.01,  sig = '**';
        elseif pval(j) < 0.05,  sig = '*';
        end
        fprintf('  %-12s %8.4f %8.4f %10s\n', ...
                param_names{j}, rho(j), pval(j), sig);
    end
    fprintf('\n  Signif. codes: *** p<0.001  ** p<0.01  * p<0.05\n\n');
end
end
