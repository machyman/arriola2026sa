%RUN_GLOBAL_SA_SIR  Complete global SA pipeline for the SIR model.
%   Reproduces the key numerical results of Chapter 9 of
%   "Foundations of Sensitivity Analysis: Theory, Computation, and Applications"
%   (Arriola & Hyman, SIAM 2026).
%
%   This script runs:
%     1. Morris screening (identify important parameters)
%     2. PRCC analysis     (fast global SA for monotone models)
%     3. Sobol indices     (variance decomposition)
%     4. Bootstrap CI      (uncertainty in Sobol estimates)
%     5. Convergence plot  (S_i vs N)
%     6. Method comparison table
%
%   QOI: peak infectious count max(I(t)) for t in [0, 90] days.
%   POIs: k (contact rate), beta (transmission), tau (infectious period),
%         L (lifespan) with ±50% variation around nominal values.
%
%   Runtime: ~5-10 minutes (Sobol with N=2000 is the bottleneck).
%   For a quick demo, set QUICK_RUN = true (N=200, no bootstrap).
%
%   Run from the repository root:
%       addpath(genpath('src'))
%       run_global_sa_sir

fprintf('=== Chapter 9: Global SA Pipeline for SIR Model ===\n\n');
rng(42);   % reproducibility

QUICK_RUN = false;   % set true for fast demo (lower accuracy)

%% -----------------------------------------------------------------------
%% Setup: model and parameter ranges
%% -----------------------------------------------------------------------
p   = sir_nominal();
ode_opts = odeset('RelTol',1e-6,'AbsTol',1e-8,'MaxStep',1.0);

% QOI: peak infectious count
function I_peak = sir_peak(pv, p_struct, ode_opts)
    k_=pv(1); beta_=pv(2); tau_=pv(3); L_=pv(4);
    y0 = [p_struct.S0; p_struct.I0; p_struct.R0_ic];
    f  = @(t,y) sir_model(t, y, k_, beta_, tau_, L_);
    try
        [~, Y] = ode45(f, [0, p_struct.T], y0, ode_opts);
        I_peak = max(Y(:,2));
    catch
        I_peak = NaN;
    end
end

model = @(pv) sir_peak(pv, p, ode_opts);

% Parameter bounds: ±50% of nominal
lb = 0.5 * [p.k, p.beta, p.tau, p.L];
ub = 1.5 * [p.k, p.beta, p.tau, p.L];
pnames = {'$k$','$\beta$','$\tau$','$L$'};
pnames_plain = {'k','beta','tau','L'};

%% -----------------------------------------------------------------------
%% PART 1: Morris screening (cheap — run first to guide Sobol)
%% -----------------------------------------------------------------------
fprintf('--- Part 1: Morris Screening ---\n');
n_morris = 15;
[mu_star, sigma_morris] = morris_screening(model, [p.k,p.beta,p.tau,p.L], ...
                                            lb, ub, n_morris, 4, ...
                                            struct('param_names', {pnames_plain}, ...
                                                   'verbose', false));
fprintf('Morris cost: %d model evaluations\n\n', n_morris*(4+1));

%% -----------------------------------------------------------------------
%% PART 2: PRCC analysis
%% -----------------------------------------------------------------------
fprintf('--- Part 2: PRCC Analysis ---\n');
N_prcc = 500;
fprintf('Generating LHS sample (N=%d)...\n', N_prcc);
X_prcc = lhs_sample(N_prcc, 4, lb, ub);

fprintf('Evaluating model (%d runs)...\n', N_prcc);
Y_prcc = zeros(N_prcc, 1);
for i = 1:N_prcc
    Y_prcc(i) = model(X_prcc(i,:));
    if mod(i,100)==0, fprintf('  %d/%d\n', i, N_prcc); end
end
fprintf('\nVerify monotonicity before PRCC (scatter matrix):\n');
fprintf('  Run: plotmatrix(X_prcc, Y_prcc) to check monotone relationships.\n\n');

[rho_prcc, pval_prcc] = compute_prcc(X_prcc, Y_prcc, pnames_plain);

%% -----------------------------------------------------------------------
%% PART 3: Sobol indices (main result)
%% -----------------------------------------------------------------------
if QUICK_RUN
    N_sobol = 200;
    n_boot  = 0;
    fprintf('--- Part 3: Sobol Indices (QUICK_RUN, N=%d, no bootstrap) ---\n',N_sobol);
else
    N_sobol = 2000;
    n_boot  = 200;
    fprintf('--- Part 3: Sobol Indices (N=%d, %d bootstrap replicates) ---\n',...
            N_sobol, n_boot);
end

fprintf('Generating Saltelli sample (cost: %d evaluations)...\n', N_sobol*(4+2));
[A, B] = saltelli_sample(N_sobol, 4, lb, ub);

fprintf('Running Sobol_Jansen estimator...\n');
[S1, ST, CI_S1, CI_ST] = sobol_jansen(model, A, B, n_boot, 0.05);

fprintf('\nSobol Results:\n');
fprintf('  %-6s %8s %8s  |  %8s %8s\n', 'Param','S1','ST','CI_S1_lo','CI_S1_hi');
fprintf('  %s\n', repmat('-',1,54));
for j = 1:4
    fprintf('  %-6s %8.4f %8.4f  |  %8.4f %8.4f\n', ...
            pnames_plain{j}, S1(j), ST(j), CI_S1(1,j), CI_S1(2,j));
end
fprintf('  Sum(S1) = %.4f  Sum(ST) = %.4f\n\n', sum(S1), sum(ST));

%% -----------------------------------------------------------------------
%% PART 4: Convergence plot (S_i vs N)
%% -----------------------------------------------------------------------
fprintf('--- Part 4: Sobol Convergence Plot ---\n');
N_vals = round(logspace(2, log10(N_sobol), 12));
N_vals = unique(N_vals);

S1_conv = zeros(length(N_vals), 4);
ST_conv = zeros(length(N_vals), 4);

for k_n = 1:length(N_vals)
    Nk = N_vals(k_n);
    [Ak, Bk] = saltelli_sample(Nk, 4, lb, ub);
    [s1k, sTk] = sobol_jansen(model, Ak, Bk);
    S1_conv(k_n,:) = s1k;
    ST_conv(k_n,:) = sTk;
    fprintf('  N=%4d: S1=[%.3f %.3f %.3f %.3f]\n', Nk, s1k(1),s1k(2),s1k(3),s1k(4));
end

% Convergence figure (replaces schematic in Ch9)
colors = [0.8 0.1 0.1; 0.1 0.5 0.8; 0.1 0.7 0.2; 0.6 0.3 0.8];
h_conv = figure();
set(h_conv,'Units','inches','Position',[1 1 8 3.5]);

subplot(1,2,1);
for j=1:4
    semilogx(N_vals, S1_conv(:,j), '-o', 'Color',colors(j,:), 'LineWidth',1.5,'MarkerSize',4);
    hold on;
end
xlabel('$N$ (samples per matrix)','Interpreter','latex');
ylabel('$\hat{S}_i$ (first-order)','Interpreter','latex');
title('Sobol S1 convergence','Interpreter','latex');
legend(pnames,'Interpreter','latex','Location','best','FontSize',9);
grid on; xlim([N_vals(1), N_vals(end)]);

subplot(1,2,2);
for j=1:4
    semilogx(N_vals, ST_conv(:,j), '--s', 'Color',colors(j,:),'LineWidth',1.5,'MarkerSize',4);
    hold on;
end
xlabel('$N$ (samples per matrix)','Interpreter','latex');
ylabel('$\hat{S}_{T_i}$ (total-order)','Interpreter','latex');
title('Sobol ST convergence','Interpreter','latex');
legend(pnames,'Interpreter','latex','Location','best','FontSize',9);
grid on; xlim([N_vals(1), N_vals(end)]);
sgtitle('Figure 9.X: Sobol index convergence for SIR peak infectious',...
        'Interpreter','latex');

%% -----------------------------------------------------------------------
%% PART 5: Summary comparison table
%% -----------------------------------------------------------------------
fprintf('\n=== Method Comparison (QOI: peak I) ===\n');
fprintf('  %-6s  %8s  %8s  %8s  %8s\n', 'Param','Local SI','PRCC','S1','ST');
fprintf('  %s\n', repmat('-',1,52));

% Compute local SI for R0 as surrogate (peak I is monotone in R0 parameters)
R0_fn = @(pv) pv(1)*pv(2)*pv(3);
pv_nom = [p.k; p.beta; p.tau; p.L];
[S_loc,~] = sensitivity_jacobian(R0_fn, pv_nom, 1);

for j=1:4
    fprintf('  %-6s  %8.4f  %8.4f  %8.4f  %8.4f\n', ...
            pnames_plain{j}, S_loc(j), rho_prcc(j), S1(j), ST(j));
end

fprintf('\n=== Pipeline complete ===\n');
