%TEST_CORE  Test suite for the core sensitivity analysis library.
%   Tests sir_nominal, sir_model, sensitivity_index, sensitivity_jacobian,
%   and tornado_plot against known analytical results.
%
%   Run from the repository root:
%       addpath(genpath('src'))
%       test_core
%
%   All tests use assert() for automated checking.  A passing run prints
%   "ALL TESTS PASSED" with no error output.

fprintf('=== test_core: Running %d tests ===\n\n', 17);
n_pass = 0;
tol    = 1e-6;   % tolerance for numerical comparisons

%% ====================================================================
%% BLOCK 1: sir_nominal
%% ====================================================================
fprintf('Block 1: sir_nominal...\n');

p = sir_nominal();

%T1.1: struct has required fields
required = {'k','beta','tau','L','N','S0','I0','R0_ic','T','gamma','mu','R0'};
for i = 1:length(required)
    assert(isfield(p, required{i}), 'Missing field: %s', required{i});
end
n_pass = n_pass + 1; fprintf('  T1.1 PASS: all fields present\n');

%T1.2: R0 consistency
assert(abs(p.R0 - p.k*p.beta*p.tau) < 1e-14, 'R0 inconsistent');
n_pass = n_pass + 1; fprintf('  T1.2 PASS: R0 = k*beta*tau = %.4f\n', p.R0);

%T1.3: derived quantities
assert(abs(p.gamma - 1/p.tau) < 1e-14, 'gamma inconsistent');
assert(abs(p.mu    - 1/p.L)   < 1e-14, 'mu inconsistent');
n_pass = n_pass + 1; fprintf('  T1.3 PASS: gamma and mu consistent\n');

%T1.4: population conservation check
assert(p.S0 + p.I0 + p.R0_ic == p.N, 'S0+I0+R0_ic must equal N');
n_pass = n_pass + 1; fprintf('  T1.4 PASS: S0+I0+R0_ic = N\n');

%% ====================================================================
%% BLOCK 2: sir_model
%% ====================================================================
fprintf('\nBlock 2: sir_model...\n');

%T2.1: output is 3x1
y0 = [p.S0; p.I0; p.R0_ic];
dy = sir_model(0, y0, p.k, p.beta, p.tau, p.L);
assert(isequal(size(dy), [3 1]), 'Output must be 3x1');
n_pass = n_pass + 1; fprintf('  T2.1 PASS: output is 3x1\n');

%T2.2: population conservation (dS+dI+dR = 0 for closed population)
% With demography: mu*N is born, mu*(S+I+R) die, net = 0
dy_sum = sum(dy);
assert(abs(dy_sum) < 1e-10, 'dS+dI+dR = %.2e (should be ~0)', dy_sum);
n_pass = n_pass + 1; fprintf('  T2.2 PASS: population conserved (dS+dI+dR = %.2e)\n', dy_sum);

%T2.3: disease-free equilibrium (I=0 -> dI/dt = 0, dS/dt = 0 at S=N)
dy_dfe = sir_model(0, [p.N; 0; 0], p.k, p.beta, p.tau, p.L);
assert(abs(dy_dfe(1)) < 1e-10, 'At DFE: dS/dt should be 0');
assert(abs(dy_dfe(2)) < 1e-10, 'At DFE: dI/dt should be 0');
n_pass = n_pass + 1; fprintf('  T2.3 PASS: disease-free equilibrium is correct\n');

%T2.4: row input handled (MLS robustness requirement)
dy_row = sir_model(0, y0', p.k, p.beta, p.tau, p.L);
assert(isequal(dy_row, dy), 'Row vs column input should give same result');
n_pass = n_pass + 1; fprintf('  T2.4 PASS: row/column input consistency\n');

%% ====================================================================
%% BLOCK 3: sensitivity_index
%% ====================================================================
fprintf('\nBlock 3: sensitivity_index...\n');

%T3.1: SI_tau(R0) = 1 (analytic)
R0_nom = p.R0;
h      = 1e-5 * p.tau;
R0_p   = p.k * p.beta * (p.tau + h);
SI_tau = sensitivity_index(R0_p, R0_nom, p.tau + h, p.tau);
assert(abs(SI_tau - 1.0) < tol, 'SI_tau(R0) should be 1, got %.8f', SI_tau);
n_pass = n_pass + 1; fprintf('  T3.1 PASS: SI_tau(R0) = %.8f (exact: 1)\n', SI_tau);

%T3.2: SI_L(R0) = 0 (L absent from R0)
R0_Lp = p.k * p.beta * p.tau;  % R0 doesn't change with L
SI_L  = sensitivity_index(R0_Lp, R0_nom, p.L * 1.01, p.L);
assert(abs(SI_L) < tol, 'SI_L(R0) should be 0, got %.2e', SI_L);
n_pass = n_pass + 1; fprintf('  T3.2 PASS: SI_L(R0) = %.2e (exact: 0)\n', SI_L);

%T3.3: dimension mismatch error
try
    sensitivity_index([1;2], 1.0, [1;2;3], 1.0);
    error('Should have thrown DimensionMismatch');
catch ME
    assert(contains(ME.identifier,'DimensionMismatch'), ...
           'Wrong error: %s', ME.identifier);
end
n_pass = n_pass + 1; fprintf('  T3.3 PASS: dimension mismatch caught correctly\n');

%% ====================================================================
%% BLOCK 4: sensitivity_jacobian
%% ====================================================================
fprintf('\nBlock 4: sensitivity_jacobian...\n');

%T4.1: known analytic result — R0 = k*beta*tau, all SIs = 1 except L
R0_fn    = @(pv) pv(1)*pv(2)*pv(3);   % ignores L = pv(4)
p_vec    = [p.k; p.beta; p.tau; p.L];
[S4, i4] = sensitivity_jacobian(R0_fn, p_vec, 1);

assert(abs(S4(1) - 1.0) < tol, 'SI_k = %.8f, expected 1', S4(1));
assert(abs(S4(2) - 1.0) < tol, 'SI_beta = %.8f, expected 1', S4(2));
assert(abs(S4(3) - 1.0) < tol, 'SI_tau = %.8f, expected 1', S4(3));
assert(abs(S4(4) - 0.0) < tol, 'SI_L = %.2e, expected 0', S4(4));
n_pass = n_pass + 1;
fprintf('  T4.1 PASS: R0 Jacobian [%.6f %.6f %.6f %.6f] (exact: [1 1 1 0])\n',...
        S4(1),S4(2),S4(3),S4(4));

%T4.2: evaluation count = 2*n_p + 1
assert(i4.n_evals == 2*4+1, 'Expected %d evals, got %d', 2*4+1, i4.n_evals);
n_pass = n_pass + 1; fprintf('  T4.2 PASS: evaluation count = %d\n', i4.n_evals);

%T4.3: multi-QOI — f(p) = [p1^2; p1*p2], p = [2; 3]
%  dq1/dp1 = 2*p1=4, dq2/dp1 = p2=3, dq2/dp2 = p1=2
%  SI_p1^q1 = (p1/q1)*dq1/dp1 = (2/4)*4 = 2
%  SI_p1^q2 = (p1/q2)*dq2/dp1 = (2/6)*3 = 1
%  SI_p2^q1 = 0
%  SI_p2^q2 = (p2/q2)*dq2/dp2 = (3/6)*2 = 1
multi_fn = @(pv) [pv(1)^2; pv(1)*pv(2)];
[S_multi, ~] = sensitivity_jacobian(multi_fn, [2;3], 2);
assert(abs(S_multi(1,1) - 2) < tol, 'S(1,1) should be 2');
assert(abs(S_multi(1,2) - 0) < tol, 'S(1,2) should be 0');
assert(abs(S_multi(2,1) - 1) < tol, 'S(2,1) should be 1');
assert(abs(S_multi(2,2) - 1) < tol, 'S(2,2) should be 1');
n_pass = n_pass + 1;
fprintf('  T4.3 PASS: multi-QOI Jacobian correct\n');

%% ====================================================================
%% BLOCK 5: tornado_plot (visual; test that it runs without error)
%% ====================================================================
fprintf('\nBlock 5: tornado_plot...\n');

%T5.1: basic call succeeds
try
    h_fig = tornado_plot([1;1;-1;0], {'$k$','$\beta$','$\tau$','$L$'}, 'R_0');
    assert(isgraphics(h_fig), 'Should return a figure handle');
    close(h_fig);
    n_pass = n_pass + 1; fprintf('  T5.1 PASS: basic tornado plot created\n');
catch ME
    fprintf('  T5.1 FAIL: %s\n', ME.message);
end

%T5.2: label mismatch error caught
try
    tornado_plot([1;2], {'only one label'}, 'Q');
    fprintf('  T5.2 FAIL: should have thrown error\n');
catch ME
    assert(contains(ME.identifier, 'LabelMismatch'));
    n_pass = n_pass + 1; fprintf('  T5.2 PASS: label mismatch caught\n');
end

%% ====================================================================
%% SUMMARY
%% ====================================================================
fprintf('\n=== SUMMARY: %d/17 tests passed ===\n', n_pass);
if n_pass == 17
    fprintf('ALL TESTS PASSED.\n');
else
    fprintf('WARNING: %d test(s) failed.\n', 17 - n_pass);
end
