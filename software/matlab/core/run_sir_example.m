%RUN_SIR_EXAMPLE  Demonstration of the core sensitivity analysis library.
%   Reproduces the key numerical results of Chapters 2-3 of
%   "Foundations of Sensitivity Analysis: From Local to Global Sensitivity"
%   (Arriola & Hyman, in preparation).
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
%       addpath(genpath('software/matlab'))
%       run_sir_example
%
%   See also: SIR_NOMINAL, SIR_MODEL, SENSITIVITY_JACOBIAN, TORNADO_PLOT

fprintf('=== Arriola & Hyman: Core SA Library Demo ===\n\n');

%% -----------------------------------------------------------------------
%% 1. Nominal parameters
%% -----------------------------------------------------------------------
p = sir_nominal();
fprintf('Nominal parameters:\n');
fprintf('  c = %g (contacts/person/day)\n', p.c);
fprintf('  beta = %g (transmission prob/contact)\n', p.beta);
fprintf('  tau_R = %g days (mean infectious period)\n', p.tau_R);
fprintf('  tau_m = %g days (mean residence time)\n', p.tau_m);
fprintf('  R0 = c*beta/(gamma_R+nu_m) = %.4f\n\n', p.R0);

%% -----------------------------------------------------------------------
%% 2. Analytic sensitivity indices for R0 = c*beta/(gamma_R+nu_m)
%%    Parameters from Chapter 2, Table 2.1.  Note that Chapter 2's own
%%    model has NO demography, so there R0 = c*beta*tau_R and all three
%%    indices equal 1 exactly; that is the self-check answer.  This
%%    library integrates the demographic equations of Chapter 6, so the
%%    tau_R and tau_m indices split as below.
%%    c and beta have SI = 1 exactly, since R0 is proportional to each.
%%    tau_R and tau_m share the remainder: SI_tau_R = tau_m/(tau_m+tau_R),
%%    SI_tau_m = tau_R/(tau_m+tau_R),
%%    which sum to 1 because gamma_R/(gamma_R+nu_m) + nu_m/(gamma_R+nu_m) = 1.
%%    Without demography SI_tau_R -> 1 and SI_tau_m -> 0, the familiar case.
%% -----------------------------------------------------------------------
fprintf('--- Analytic SI for R0 ---\n');
fprintf('  SI_c(R0)     = c/R0 * dR0/dc    = %g  (exact: 1)\n', ...
        (p.c / p.R0) * p.beta * p.tau_R);
fprintf('  SI_beta(R0)  = beta/R0 * dR0/dbeta = %g  (exact: 1)\n', ...
        (p.beta / p.R0) * p.c * p.tau_R);
% dR0/dtau_R = c*beta*gamma_R^2/(gamma_R+nu_m)^2, with gamma_R = 1/tau_R:
dR0_dtau_R = p.c * p.beta * (1/p.tau_R^2) / (p.gamma_R + p.nu_m)^2;
dR0_dtau_m = p.c * p.beta * (1/p.tau_m^2) / (p.gamma_R + p.nu_m)^2;
fprintf('  SI_tau_R(R0) = tau_R/R0 * dR0/dtau_R = %g  (exact: %g)\n', ...
        (p.tau_R / p.R0) * dR0_dtau_R, p.tau_m / (p.tau_m + p.tau_R));
fprintf('  SI_tau_m(R0) = tau_m/R0 * dR0/dtau_m = %g  (exact: %g)\n\n', ...
        (p.tau_m / p.R0) * dR0_dtau_m, p.tau_R / (p.tau_m + p.tau_R));

%% -----------------------------------------------------------------------
%% 3. Numerical SI Jacobian via sensitivity_jacobian (Chapter 3)
%%    Model: R0 as function of [c, beta, tau_R, tau_m]
%% -----------------------------------------------------------------------
fprintf('--- Numerical SI Jacobian via centered FD ---\n');

R0_model = @(pv) pv(1) * pv(2) * pv(3);   % R0 = c * beta * tau_R (tau_m absent)
p_nom_vec = [p.c; p.beta; p.tau_R; p.tau_m];   % 4-POI vector

[S_mat, info] = sensitivity_jacobian(R0_model, p_nom_vec, 1);

param_names = {'c', 'beta', 'tau_R', 'tau_m'};
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
labels = {'$c$', '$\beta$', '$\tau_R$', '$\tau_m$'};

h_fig = tornado_plot(SI_R0, labels, 'R_0');
title('Sensitivity indices for $R_0 = c\beta\tau_R$ (Figure 2.1)', ...
      'Interpreter','latex','FontSize',12);
fprintf('Tornado plot created (Figure 1).\n\n');

%% -----------------------------------------------------------------------
%% 5. SIR epidemic curve (Chapter 4 setup)
%% -----------------------------------------------------------------------
fprintf('--- SIR epidemic simulation ---\n');

y0 = [p.S0; p.I0; p.R0_ic];
f  = @(t,y) sir_model(t, y, p.c, p.beta, p.tau_R, p.tau_m);

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
sgtitle(sprintf('SIR model: $c=%g$, $\\beta=%g$, $\\tau_R=%g$, $\\tau_m=%g$, $R_0=%.1f$', ...
                p.c, p.beta, p.tau_R, p.tau_m, p.R0), 'Interpreter','latex');

fprintf('=== Demo complete. ===\n');
