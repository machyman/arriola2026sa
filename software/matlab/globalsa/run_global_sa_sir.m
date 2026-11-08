%RUN_GLOBAL_SA_SIR  Complete global SA pipeline for the SIR model.
%   Reproduces the key numerical results of Chapter 9 of
%   "Foundations of Sensitivity Analysis: From Local to Global Sensitivity"
%   (Arriola & Hyman, in preparation).
%
%   This script runs:
%     1. Morris screening (identify important parameters)
%     2. PRCC analysis     (fast global SA for monotone models)
%     3. Sobol indices     (variance decomposition)
%     4. Bootstrap CI      (uncertainty in Sobol estimates)
%     5. Convergence plot  (S_i vs M)
%     6. Method comparison table
%
%   QOI: peak infectious count max(I(t)) for t in [0, 90] days.
%   POIs: c (contact rate), beta (transmission), tau_R (infectious period),
%         tau_m (mean residence time) with ±50% variation around nominal values.
%
%   Runtime: ~5-10 minutes (Sobol with M=2048 is the bottleneck).
%   For a quick demo, set QUICK_RUN = true (M=200, no bootstrap).
%
%   Run from the repository root:
%       addpath(genpath('software/matlab'))
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
    c_=pv(1); beta_=pv(2); tau_R_=pv(3); tau_m_=pv(4);
    y0 = [p_struct.S0; p_struct.I0; p_struct.R0_ic];
    f  = @(t,y) sir_model(t, y, c_, beta_, tau_R_, tau_m_);
    try
        [~, Y] = ode45(f, [0, p_struct.T], y0, ode_opts);
        I_peak = max(Y(:,2));
    catch
        I_peak = NaN;
    end
end

model = @(pv) sir_peak(pv, p, ode_opts);

% Parameter bounds: ±50% of nominal
lb = 0.5 * [p.c, p.beta, p.tau_R, p.tau_m];
ub = 1.5 * [p.c, p.beta, p.tau_R, p.tau_m];
pnames = {'$c$','$\beta$','$\tau_R$','$\tau_m$'};
pnames_plain = {'c','beta','tau_R','tau_m'};

%% -----------------------------------------------------------------------
%% PART 1: Morris screening (cheap — run first to guide Sobol)
%% -----------------------------------------------------------------------
fprintf('--- Part 1: Morris Screening ---\n');
n_morris = 15;
[mu_star, sigma_morris] = morris_screening(model, [p.c,p.beta,p.tau_R,p.tau_m], ...
                                            lb, ub, n_morris, 4, ...
                                            struct('param_names', {pnames_plain}, ...
                                                   'verbose', false));
fprintf('Morris cost: %d model evaluations\n\n', n_morris*(4+1));

%% -----------------------------------------------------------------------
%% PART 2: PRCC analysis
%% -----------------------------------------------------------------------
fprintf('--- Part 2: PRCC Analysis ---\n');
M_prcc = 500;
fprintf('Generating LHS sample (M=%d)...\n', M_prcc);
X_prcc = lhs_sample(M_prcc, 4, lb, ub);

fprintf('Evaluating model (%d runs)...\n', M_prcc);
Y_prcc = zeros(M_prcc, 1);
for i = 1:M_prcc
    Y_prcc(i) = model(X_prcc(i,:));
    if mod(i,100)==0, fprintf('  %d/%d\n', i, M_prcc); end
end
fprintf('\nVerify monotonicity before PRCC (scatter matrix):\n');
fprintf('  Run: plotmatrix(X_prcc, Y_prcc) to check monotone relationships.\n\n');

[prcc, pval_prcc] = compute_prcc(X_prcc, Y_prcc, pnames_plain);

%% -----------------------------------------------------------------------
%% PART 3: Sobol indices (main result)
%% -----------------------------------------------------------------------
if QUICK_RUN
    M_sobol = 200;
    n_boot  = 0;
    fprintf('--- Part 3: Sobol Indices (QUICK_RUN, M=%d, no bootstrap) ---\n',M_sobol);
else
    M_sobol = 2048;   % power of two: Sobol' balance holds in blocks of 2^k
    n_boot  = 200;
    fprintf('--- Part 3: Sobol Indices (M=%d, %d bootstrap replicates) ---\n',...
            M_sobol, n_boot);
end

fprintf('Generating Saltelli sample (cost: %d evaluations)...\n', M_sobol*(4+2));
[A, B] = saltelli_sample(M_sobol, 4, lb, ub, true);   % true: use the Sobol' sequence

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
%% PART 4: Convergence plot (S_i vs M)
%% -----------------------------------------------------------------------
fprintf('--- Part 4: Sobol Convergence Plot ---\n');
% Powers of two, so every point in the sweep keeps the Sobol' balance
% property (Part 5 of the Chapter 9 laboratory).
M_vals = 2.^(7:log2(M_sobol));

S1_conv = zeros(length(M_vals), 4);
ST_conv = zeros(length(M_vals), 4);

for k_n = 1:length(M_vals)
    Mk = M_vals(k_n);
    [Ak, Bk] = saltelli_sample(Mk, 4, lb, ub, true);
    [s1k, sTk] = sobol_jansen(model, Ak, Bk);
    S1_conv(k_n,:) = s1k;
    ST_conv(k_n,:) = sTk;
    fprintf('  M=%4d: S1=[%.3f %.3f %.3f %.3f]\n', Mk, s1k(1),s1k(2),s1k(3),s1k(4));
end

% Convergence figure (replaces schematic in Ch9)
colors = [0.8 0.1 0.1; 0.1 0.5 0.8; 0.1 0.7 0.2; 0.6 0.3 0.8];
h_conv = figure();
set(h_conv,'Units','inches','Position',[1 1 8 3.5]);

subplot(1,2,1);
for j=1:4
    semilogx(M_vals, S1_conv(:,j), '-o', 'Color',colors(j,:), 'LineWidth',1.5,'MarkerSize',4);
    hold on;
end
xlabel('$M$ (samples per matrix)','Interpreter','latex');
ylabel('$\hat{\mathcal{S}}_i$ (first-order)','Interpreter','latex');
title('Sobol S1 convergence','Interpreter','latex');
legend(pnames,'Interpreter','latex','Location','best','FontSize',9);
grid on; xlim([M_vals(1), M_vals(end)]);

subplot(1,2,2);
for j=1:4
    semilogx(M_vals, ST_conv(:,j), '--s', 'Color',colors(j,:),'LineWidth',1.5,'MarkerSize',4);
    hold on;
end
xlabel('$M$ (samples per matrix)','Interpreter','latex');
ylabel('$\hat{\mathcal{S}}_{T_i}$ (total-order)','Interpreter','latex');
title('Sobol ST convergence','Interpreter','latex');
legend(pnames,'Interpreter','latex','Location','best','FontSize',9);
grid on; xlim([M_vals(1), M_vals(end)]);
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
pv_nom = [p.c; p.beta; p.tau_R; p.tau_m];
[S_loc,~] = sensitivity_jacobian(R0_fn, pv_nom, 1);

for j=1:4
    fprintf('  %-6s  %8.4f  %8.4f  %8.4f  %8.4f\n', ...
            pnames_plain{j}, S_loc(j), prcc(j), S1(j), ST(j));
end

fprintf('\n=== Pipeline complete ===\n');
