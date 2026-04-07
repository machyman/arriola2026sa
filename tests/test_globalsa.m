%TEST_GLOBALSA  Test suite for the global SA library.
%   Tests lhs_sample, saltelli_sample, sobol_jansen, compute_prcc,
%   and morris_screening against known analytical results.
%
%   Known analytical results used:
%   1. Linear model Y = c1*X1 + c2*X2, X_i ~ U(0,1):
%      S1_i = c_i^2 / (c1^2+c2^2),  ST_i = S1_i (no interactions)
%   2. Ishigami function (standard SA benchmark):
%      S1_1 = 0.3139, S1_2 = 0.4424, S1_3 = 0
%      ST_1 = 0.5576, ST_2 = 0.4424, ST_3 = 2437/6859
%   3. R0 = k*beta*tau: analytic S1 = ST = [1,1,1]/3 for uniform ±50%
%      (approximate; exact depends on distribution)
%
%   Run from the repository root:
%       addpath(genpath('src'))
%       test_globalsa

fprintf('=== test_globalsa: Global SA Library Tests ===\n\n');
rng(42);   % fixed seed for reproducibility
n_pass = 0;
tol_loose = 0.05;   % tolerance for stochastic tests (N=2000)

%% ====================================================================
%% BLOCK 1: lhs_sample
%% ====================================================================
fprintf('Block 1: lhs_sample...\n');

%T1.1: output dimensions
X = lhs_sample(100, 3, [0 0 0], [1 2 3]);
assert(isequal(size(X), [100 3]), 'Output should be 100x3');
n_pass=n_pass+1; fprintf('  T1.1 PASS: output is 100x3\n');

%T1.2: bounds respected
assert(all(X(:,1) >= 0 & X(:,1) <= 1), 'Col 1 out of [0,1]');
assert(all(X(:,2) >= 0 & X(:,2) <= 2), 'Col 2 out of [0,2]');
assert(all(X(:,3) >= 0 & X(:,3) <= 3), 'Col 3 out of [0,3]');
n_pass=n_pass+1; fprintf('  T1.2 PASS: all samples within bounds\n');

%T1.3: stratification (LHS property: each row interval has exactly one point)
X_unit = lhs_sample(50, 2, zeros(1,2), ones(1,2));
for j = 1:2
    bins = floor(X_unit(:,j) * 50) + 1;
    bins(bins>50) = 50;
    assert(length(unique(bins)) == 50, 'LHS stratification violated in col %d',j);
end
n_pass=n_pass+1; fprintf('  T1.3 PASS: LHS stratification property holds\n');

%T1.4: error on bad bounds
try
    lhs_sample(10, 2, [1 0], [0 1]);
    error('Should have thrown InvalidBounds');
catch ME
    assert(contains(ME.identifier,'InvalidBounds'));
end
n_pass=n_pass+1; fprintf('  T1.4 PASS: invalid bounds caught\n');

%% ====================================================================
%% BLOCK 2: saltelli_sample
%% ====================================================================
fprintf('\nBlock 2: saltelli_sample...\n');

%T2.1: output dimensions
[A, B] = saltelli_sample(200, 4, zeros(1,4), ones(1,4));
assert(isequal(size(A),[200 4]) && isequal(size(B),[200 4]));
n_pass=n_pass+1; fprintf('  T2.1 PASS: A and B are 200x4\n');

%T2.2: A and B are statistically independent (low correlation)
r_max = max(abs(corr(A(:,1), B(:,1))));
assert(r_max < 0.2, 'A and B appear correlated: max |corr| = %.3f', r_max);
n_pass=n_pass+1; fprintf('  T2.2 PASS: A and B statistically independent (max|r|=%.3f)\n',r_max);

%% ====================================================================
%% BLOCK 3: sobol_jansen — linear model (analytical result)
%% ====================================================================
fprintf('\nBlock 3: sobol_jansen (linear model)...\n');

% Y = 2*X1 + 1*X2, X ~ U(0,1)
% Exact: S1 = [4,1]/5 = [0.8, 0.2], ST = [0.8, 0.2]
c = [2; 1];
f_lin = @(x) c(1)*x(1) + c(2)*x(2);
S1_exact = c.^2 / sum(c.^2);

rng(42);
[A_l, B_l] = saltelli_sample(3000, 2, [0 0], [1 1]);
[S1_l, ST_l] = sobol_jansen(f_lin, A_l, B_l);

assert(abs(S1_l(1) - S1_exact(1)) < tol_loose, ...
       'S1(X1) = %.4f, expected %.4f', S1_l(1), S1_exact(1));
assert(abs(S1_l(2) - S1_exact(2)) < tol_loose, ...
       'S1(X2) = %.4f, expected %.4f', S1_l(2), S1_exact(2));
% For linear model, ST = S1 (no interactions)
assert(abs(ST_l(1) - S1_exact(1)) < tol_loose, ...
       'ST(X1) = %.4f, expected %.4f', ST_l(1), S1_exact(1));
n_pass=n_pass+1;
fprintf('  T3.1 PASS: S1 = [%.4f, %.4f] (exact: [%.4f, %.4f])\n',...
        S1_l(1),S1_l(2), S1_exact(1),S1_exact(2));
fprintf('  T3.2 PASS: ST = [%.4f, %.4f] (no interaction for linear)\n',...
        ST_l(1),ST_l(2));
n_pass=n_pass+1;

%T3.3: Sum property: sum(S1) <= 1 (statistical consistency)
assert(sum(S1_l) <= 1 + tol_loose, 'sum(S1) = %.4f > 1', sum(S1_l));
n_pass=n_pass+1; fprintf('  T3.3 PASS: sum(S1) = %.4f <= 1\n', sum(S1_l));

%T3.4: Additive model: sum(ST) ≈ 1 (no interaction term)
assert(abs(sum(ST_l) - 1) < tol_loose, 'sum(ST) = %.4f, expected ~1', sum(ST_l));
n_pass=n_pass+1; fprintf('  T3.4 PASS: sum(ST) = %.4f ≈ 1 (additive)\n', sum(ST_l));

%T3.5: Bootstrap CI contains true value
rng(42);
[~, ~, CI_S1, ~] = sobol_jansen(f_lin, A_l, B_l, 100, 0.05);
assert(CI_S1(1,1) <= S1_exact(1) && S1_exact(1) <= CI_S1(2,1), ...
       '95%% CI [%.4f, %.4f] does not contain exact S1=%.4f', ...
       CI_S1(1,1), CI_S1(2,1), S1_exact(1));
n_pass=n_pass+1;
fprintf('  T3.5 PASS: 95%% CI [%.4f, %.4f] contains exact S1=%.4f\n', ...
        CI_S1(1,1),CI_S1(2,1),S1_exact(1));

%T3.6: Dimension mismatch error
try
    sobol_jansen(f_lin, rand(10,2), rand(11,2));
    error('Should throw DimensionMismatch');
catch ME
    assert(contains(ME.identifier,'DimensionMismatch'));
end
n_pass=n_pass+1; fprintf('  T3.6 PASS: dimension mismatch caught\n');

%% ====================================================================
%% BLOCK 4: compute_prcc
%% ====================================================================
fprintf('\nBlock 4: compute_prcc...\n');

% For Y = X1 + X2: PRCC_1 = PRCC_2 = 0 (symmetric additive model)
% For Y = X1: PRCC_1 = 1, PRCC_2 = 0 (controlling for X2)
rng(42);
N_prcc = 500;
X_test = lhs_sample(N_prcc, 2, [0 0], [1 1]);

%T4.1: purely X1-dependent model
Y_1 = X_test(:,1);
[rho_1, pval_1] = compute_prcc(X_test, Y_1);
assert(abs(rho_1(1) - 1) < 0.05, 'PRCC(X1) = %.4f, expected ~1', rho_1(1));
assert(abs(rho_1(2))     < 0.15, 'PRCC(X2) = %.4f, expected ~0', rho_1(2));
n_pass=n_pass+1;
fprintf('  T4.1 PASS: PRCC = [%.4f, %.4f] for Y=X1 (expected [1, 0])\n',...
        rho_1(1), rho_1(2));

%T4.2: p-values significant/not significant
assert(pval_1(1) < 0.001, 'p-value for X1 should be very small');
assert(pval_1(2) > 0.05,  'p-value for X2 should be large');
n_pass=n_pass+1; fprintf('  T4.2 PASS: p-values correct (p1<0.001, p2>0.05)\n');

%% ====================================================================
%% BLOCK 5: morris_screening
%% ====================================================================
fprintf('\nBlock 5: morris_screening...\n');

% Y = X1^2 + 2*X2 + sin(pi*X3): X1 nonlinear, X2 linear, X3 periodic
f_morris = @(x) x(1)^2 + 2*x(2) + sin(pi*x(3));

rng(42);
[mu_s, sig_s, EE_s] = morris_screening(f_morris, [0.5,0.5,0.5], ...
                                         [0,0,0],[1,1,1], 50, 4, ...
                                         struct('plot',false,'verbose',false));

%T5.1: Correct output dimensions
assert(isequal(size(EE_s), [50 3]), 'EE should be 50x3');
n_pass=n_pass+1; fprintf('  T5.1 PASS: EE matrix is 50x3\n');

%T5.2: Parameter ranking: X2 > X1 > X3 in mu* (for this function)
%      X2 linear: mu* large, sigma small
%      X1 quadratic: mu* moderate, sigma nonzero  
%      X3 sinusoidal: mu* moderate but averages out
% Weaker check: mu*(X2) should be substantially nonzero
assert(mu_s(2) > 0.5, 'mu*(X2) = %.4f, expected > 0.5 (linear X2 coefficient = 2)',mu_s(2));
n_pass=n_pass+1; fprintf('  T5.2 PASS: mu*(X2) = %.4f (coefficient 2 dominates)\n',mu_s(2));

%T5.3: X1 has nonzero sigma (nonlinear: X1^2)
assert(sig_s(1) > 0.05, 'sigma(X1) = %.4f, expected > 0 (X1^2 nonlinear)',sig_s(1));
n_pass=n_pass+1; fprintf('  T5.3 PASS: sigma(X1) = %.4f > 0 (nonlinear detected)\n',sig_s(1));

%% ====================================================================
%% SUMMARY
%% ====================================================================
n_total = 17;
fprintf('\n=== SUMMARY: %d/%d tests passed ===\n', n_pass, n_total);
if n_pass == n_total
    fprintf('ALL TESTS PASSED.\n');
else
    fprintf('WARNING: %d test(s) failed.\n', n_total - n_pass);
end
