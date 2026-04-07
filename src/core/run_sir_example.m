%RUN_SIR_EXAMPLE  Demonstration of the core sensitivity analysis library.
%   Reproduces the key numerical results of Chapters 2-3 of
%   "Foundations of Sensitivity Analysis: Theory, Computation, and Applications"
%   (Arriola & Hyman, SIAM 2026).
%
%   This script:
%     1. Loads nominal parameters (SIR_NOMINAL)
%     2. Verifies analytical SI values for R0 (Chapter 2)
%     3. Computes the full SI Jacobian for R0 via centered FD (Chapter 3)
%     4. Produces the tornado plot (Chapter 2, Figure 2.1)
%     5. Solves the SIR ODE and plots the epidemic curve (Chapter 4 setup)
%
%   Run this script from the repository root:
%       cd arriola2026sa
%       addpath(genpath('src'))
%       run_sir_example
%
%   See also: SIR_NOMINAL, SIR_MODEL, SENSITIVITY_JACOBIAN, TORNADO_PLOT

fprintf('=== Arriola & Hyman: Core SA Library Demo ===\n\n');

%% -----------------------------------------------------------------------
%% 1. Nominal parameters
%% -----------------------------------------------------------------------
p = sir_nominal();
fprintf('Nominal parameters:\n');
fprintf('  k = %g (contacts/person/day)\n', p.k);
fprintf('  beta = %g (transmission prob/contact)\n', p.beta);
fprintf('  tau = %g days (mean infectious period)\n', p.tau);
fprintf('  L = %g days (mean lifespan)\n', p.L);
fprintf('  R0 = k*beta*tau = %.4f\n\n', p.R0);

%% -----------------------------------------------------------------------
%% 2. Analytic sensitivity indices for R0 = k * beta * tau
%%    (Chapter 2, Table 2.1 and self-check answer)
%%    All three POIs have SI = 1 (or -1 for gamma = 1/tau)
%% -----------------------------------------------------------------------
fprintf('--- Analytic SI for R0 ---\n');
fprintf('  SI_k(R0)    = k/R0 * dR0/dk    = %g  (exact: 1)\n', ...
        (p.k / p.R0) * p.beta * p.tau);
fprintf('  SI_beta(R0) = beta/R0 * dR0/db = %g  (exact: 1)\n', ...
        (p.beta / p.R0) * p.k * p.tau);
fprintf('  SI_tau(R0)  = tau/R0 * dR0/dt  = %g  (exact: 1)\n', ...
        (p.tau / p.R0) * p.k * p.beta);
% L does not appear in R0, so SI_L(R0) = 0
fprintf('  SI_L(R0)    = 0 (L absent from R0)  (exact: 0)\n\n');

%% -----------------------------------------------------------------------
%% 3. Numerical SI Jacobian via sensitivity_jacobian (Chapter 3)
%%    Model: R0 as function of [k, beta, tau, L]
%% -----------------------------------------------------------------------
fprintf('--- Numerical SI Jacobian via centered FD ---\n');

R0_model = @(pv) pv(1) * pv(2) * pv(3);   % R0 = k * beta * tau (L absent)
p_nom_vec = [p.k; p.beta; p.tau; p.L];     % 4-POI vector

[S_mat, info] = sensitivity_jacobian(R0_model, p_nom_vec, 1);

param_names = {'k', 'beta', 'tau', 'L'};
fprintf('  SI values (n_evals = %d):\n', info.n_evals);
for j = 1:4
    fprintf('    SI_%s(R0) = %10.7f  (error indicator: %.2e)\n', ...
            param_names{j}, S_mat(j), info.err_est(j));
end
fprintf('\n');

%% -----------------------------------------------------------------------
%% 4. Tornado plot (Chapter 2, reproduces Figure 2.1)
%% -----------------------------------------------------------------------
SI_R0  = S_mat(:);
labels = {'$k$', '$\beta$', '$\tau$', '$L$'};

h_fig = tornado_plot(SI_R0, labels, 'R_0');
title('Sensitivity indices for $R_0 = k\beta\tau$ (Figure 2.1)', ...
      'Interpreter','latex','FontSize',12);
fprintf('Tornado plot created (Figure 1).\n\n');

%% -----------------------------------------------------------------------
%% 5. SIR epidemic curve (Chapter 4 setup)
%% -----------------------------------------------------------------------
fprintf('--- SIR epidemic simulation ---\n');

y0 = [p.S0; p.I0; p.R0_ic];
f  = @(t,y) sir_model(t, y, p.k, p.beta, p.tau, p.L);

ode_opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10, 'MaxStep', 0.5);
[t, Y]   = ode45(f, [0 p.T], y0, ode_opts);

[I_peak, t_idx] = max(Y(:,2));
fprintf('  Peak infectious: I_max = %.1f at t = %.1f days\n', ...
        I_peak, t(t_idx));
fprintf('  Final state: S=%.1f, I=%.1f, R=%.1f\n', ...
        Y(end,1), Y(end,2), Y(end,3));
fprintf('  Attack rate: %.1f%%\n\n', 100*(1 - Y(end,1)/p.N));

figure;
subplot(1,2,1);
plot(t, Y(:,1), 'b-', t, Y(:,2), 'r-', t, Y(:,3), 'g-', 'LineWidth', 1.5);
xlabel('Time (days)','Interpreter','latex');
ylabel('Count','Interpreter','latex');
legend({'$S(t)$','$I(t)$','$R(t)$'}, 'Interpreter','latex','Location','east');
title('SIR epidemic curve','Interpreter','latex');
grid on;

subplot(1,2,2);
semilogy(t, max(Y(:,2), 1e-10), 'r-', 'LineWidth',1.5);
xlabel('Time (days)','Interpreter','latex');
ylabel('$I(t)$ (log scale)','Interpreter','latex');
title('Infectious compartment (log scale)','Interpreter','latex');
grid on;
sgtitle(sprintf('SIR model: $k=%g$, $\\beta=%g$, $\\tau=%g$, $L=%g$, $R_0=%.1f$', ...
                p.k, p.beta, p.tau, p.L, p.R0), 'Interpreter','latex');

fprintf('=== Demo complete. ===\n');
