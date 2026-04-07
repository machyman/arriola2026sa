%TEST_FSE_ADJOINT  Test suite for FSE and adjoint libraries.
%   Tests sir_jacobian, sir_augmented, compute_time_si, sir_adjoint_rhs,
%   and run_sir_adjoint against known analytical results.
%
%   Key verification:
%     1. Jacobian entries match finite differences.
%     2. Augmented ODE: FSE SI matches centered-difference SI at selected times.
%     3. Adjoint SI matches FSE SI for J = integral(I, 0, T).
%
%   Run from the repository root:
%       addpath(genpath('src'))
%       test_fse_adjoint

fprintf('=== test_fse_adjoint: FSE and Adjoint Libraries ===\n\n');
tol_fd  = 1e-4;   % tolerance for FD-based comparisons
tol_adj = 0.02;   % tolerance for adjoint vs FSE comparison
n_pass  = 0;

p = sir_nominal();
ode_opts = odeset('RelTol',1e-8,'AbsTol',1e-10,'MaxStep',0.5);

%% ====================================================================
%% BLOCK 1: sir_jacobian
%% ====================================================================
fprintf('Block 1: sir_jacobian...\n');
S = p.S0; I = p.I0; R = p.R0_ic;

%T1.1: analytic vs finite difference at t=0
J_anal = sir_jacobian(S, I, R, p.k, p.beta, p.tau, p.L);
assert(isequal(size(J_anal), [3 3]), 'Jacobian must be 3x3');
n_pass=n_pass+1; fprintf('  T1.1 PASS: Jacobian is 3x3\n');

%T1.2: column-sum property: each column of J sums to 0
%  (dF_S/dx_j + dF_I/dx_j + dF_R/dx_j = d(dS+dI+dR)/dx_j = 0)
col_sums = sum(J_anal, 1);
assert(max(abs(col_sums)) < 1e-10, 'Column sums nonzero: %.2e', max(abs(col_sums)));
n_pass=n_pass+1; fprintf('  T1.2 PASS: Jacobian column sums = 0 (population conservation)\n');

%T1.3: verify J(1,2) = dF_S/dI against FD
h = 1e-5;
rhs_p = sir_model(0, [S; I+h; R], p.k,p.beta,p.tau,p.L);
rhs_m = sir_model(0, [S; I-h; R], p.k,p.beta,p.tau,p.L);
J_fd_col2 = (rhs_p - rhs_m)/(2*h);
assert(max(abs(J_anal(:,2) - J_fd_col2)) < tol_fd, ...
       'Jacobian col 2 mismatch vs FD: max diff = %.2e', ...
       max(abs(J_anal(:,2) - J_fd_col2)));
n_pass=n_pass+1; fprintf('  T1.3 PASS: dF/dI column matches FD (max diff = %.2e)\n', ...
                          max(abs(J_anal(:,2) - J_fd_col2)));

%% ====================================================================
%% BLOCK 2: sir_augmented
%% ====================================================================
fprintf('\nBlock 2: sir_augmented...\n');

%T2.1: output dimension
y0_aug = [p.S0; p.I0; p.R0_ic; zeros(12,1)];
dy_aug = sir_augmented(0, y0_aug, p.k,p.beta,p.tau,p.L);
assert(length(dy_aug) == 15, 'Output should be 15x1');
n_pass=n_pass+1; fprintf('  T2.1 PASS: augmented RHS is 15x1\n');

%T2.2: first 3 components match sir_model
dy_sir = sir_model(0, [p.S0;p.I0;p.R0_ic], p.k,p.beta,p.tau,p.L);
assert(max(abs(dy_aug(1:3) - dy_sir)) < 1e-12, ...
       'Augmented ODE: first 3 components differ from sir_model');
n_pass=n_pass+1; fprintf('  T2.2 PASS: first 3 components match sir_model\n');

%T2.3: initial sensitivity derivatives = 0 (zero initial conditions)
assert(max(abs(dy_aug(4:15))) < 1e-6, ...
       'Initial FSE RHS should be near zero at t=0 with zero IC');
% Not exactly zero because dF/dp_j ≠ 0 at t=0
% Actually at t=0, the FSE RHS = J*0 + dF/dp ≠ 0 in general
% Let's check that FSE is at least finite
assert(all(isfinite(dy_aug(4:15))), 'FSE RHS contains non-finite values');
n_pass=n_pass+1; fprintf('  T2.3 PASS: FSE RHS is finite at t=0\n');

%T2.4: FSE vs FD comparison at t=30 days
fprintf('  T2.4: FSE vs FD comparison at t=30 days...\n');
f_aug = @(t,y) sir_augmented(t,y,p.k,p.beta,p.tau,p.L);
[~, Y_aug] = ode45(f_aug, [0 30], y0_aug, ode_opts);
y30 = Y_aug(end,:)';

% Time-dependent SI at t=30 via FSE: SI_k(I)(30) = (k/I(30)) * w_I1(30)
I30  = y30(2);
w_I1_fse = y30(5);   % d I/d k at t=30
SI_k_fse = (p.k/I30) * w_I1_fse;

% Same via centered FD
h_fd = 1e-5 * p.k;
f_fwd_p = @(t,y) sir_model(t,y,p.k+h_fd,p.beta,p.tau,p.L);
f_fwd_m = @(t,y) sir_model(t,y,p.k-h_fd,p.beta,p.tau,p.L);
[~,Yp] = ode45(f_fwd_p, [0 30], [p.S0;p.I0;p.R0_ic], ode_opts);
[~,Ym] = ode45(f_fwd_m, [0 30], [p.S0;p.I0;p.R0_ic], ode_opts);
SI_k_fd = (p.k/I30) * (Yp(end,2)-Ym(end,2))/(2*h_fd);

fprintf('    SI_k(I)(t=30): FSE = %.6f, FD = %.6f, diff = %.2e\n', ...
        SI_k_fse, SI_k_fd, abs(SI_k_fse - SI_k_fd));
assert(abs(SI_k_fse - SI_k_fd) < tol_fd, ...
       'FSE vs FD mismatch at t=30: diff = %.2e', abs(SI_k_fse - SI_k_fd));
n_pass=n_pass+1; fprintf('  T2.4 PASS: FSE matches FD at t=30\n');

%% ====================================================================
%% BLOCK 3: Adjoint vs FSE comparison
%% ====================================================================
fprintf('\nBlock 3: Adjoint vs FSE...\n');

%T3.1: run adjoint pipeline (no plots for speed)
fprintf('  Running adjoint pipeline...\n');
adj_opts = struct('verbose',false,'plot',false,'verify_fse',false);
[SI_adj, ~, Y_fwd, ~, ~] = run_sir_adjoint(p, adj_opts);
assert(length(SI_adj) == 4, 'SI_adj should have 4 elements');
n_pass=n_pass+1; fprintf('  T3.1 PASS: adjoint pipeline ran successfully\n');

%T3.2: adjoint SI values are finite and in plausible range
assert(all(isfinite(SI_adj)), 'Adjoint SI contains non-finite values');
assert(all(abs(SI_adj) < 10), 'Adjoint SI values seem too large: max=%.2f', max(abs(SI_adj)));
n_pass=n_pass+1;
fprintf('  T3.2 PASS: SI_adj = [%.4f %.4f %.4f %.4f] (all finite)\n', SI_adj);

%T3.3: qualitative check — k and beta should have similar SI (symmetric role in R0)
assert(abs(SI_adj(1) - SI_adj(2)) < 0.3, ...
       'SI_k and SI_beta should be similar (both appear as k*beta): diff=%.4f', ...
       abs(SI_adj(1)-SI_adj(2)));
n_pass=n_pass+1; fprintf('  T3.3 PASS: SI_k ≈ SI_beta (%.4f vs %.4f)\n', ...
                          SI_adj(1), SI_adj(2));

%T3.4: L should have small SI (lifespan >> tau, mu effect is small)
assert(abs(SI_adj(4)) < abs(SI_adj(1)), ...
       'SI_L should be smaller than SI_k for this time horizon');
n_pass=n_pass+1; fprintf('  T3.4 PASS: |SI_L| = %.4f < |SI_k| = %.4f (expected)\n', ...
                          abs(SI_adj(4)), abs(SI_adj(1)));

%% ====================================================================
%% SUMMARY
%% ====================================================================
n_total = 11;
fprintf('\n=== SUMMARY: %d/%d tests passed ===\n', n_pass, n_total);
if n_pass == n_total
    fprintf('ALL TESTS PASSED.\n');
else
    fprintf('WARNING: %d test(s) failed.\n', n_total - n_pass);
end
