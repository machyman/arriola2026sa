function [SI_adj, t_fwd, Y_fwd, t_adj, LAM] = run_sir_adjoint(p, options)
%RUN_SIR_ADJOINT  Complete SIR adjoint sensitivity pipeline.
%   Runs the full forward-then-backward adjoint computation described in
%   Chapter 6 of Arriola & Hyman:
%     1. Forward ODE: solve SIR from t=0 to t=T; store dense output.
%     2. Build interpolants for S(t), I(t), R(t).
%     3. Backward ODE: solve adjoint from t=T to t=0.
%     4. Integrate: SI_j = -integral(lambda^T * dF/dp_j, 0, T).
%     5. Compare with FSE result (optional verification).
%
%   [SI_ADJ, T_FWD, Y_FWD, T_ADJ, LAM] = RUN_SIR_ADJOINT(P)
%
%   Inputs:
%       p       - parameter struct from SIR_NOMINAL
%       options - (optional) struct:
%           .verbose    : print progress [default: true]
%           .plot       : generate Figure 6.4 [default: true]
%           .save_pdf   : filename for figure [default: '']
%           .verify_fse : compare with FSE result [default: true]
%
%   Outputs:
%       SI_adj  - 1x4 vector of adjoint-computed sensitivity indices
%                 [SI_k, SI_beta, SI_tau, SI_L] for J = integral(I, 0, T)
%       t_fwd   - forward solution time vector
%       Y_fwd   - forward solution [S, I, R] (n_t x 3)
%       t_adj   - adjoint solution time vector (reversed)
%       LAM     - adjoint solution [lam_S, lam_I, lam_R] (n_t x 3)
%
%   Reference: Arriola & Hyman, SIAM 2026, Ch. 6.
%   See also: SIR_ADJOINT_RHS, SIR_AUGMENTED, SIR_NOMINAL, PLOT_TIME_SI

%% --- Defaults ----------------------------------------------------------
if nargin < 2 || isempty(options), options = struct(); end
verbose    = getfield_default(options, 'verbose',    true);
do_plot    = getfield_default(options, 'plot',       true);
save_pdf   = getfield_default(options, 'save_pdf',   '');
verify_fse = getfield_default(options, 'verify_fse', true);

ode_opts = odeset('RelTol',1e-8,'AbsTol',1e-10,'MaxStep',0.5);

%% -----------------------------------------------------------------------
%% STEP 1: Forward SIR solve
%% -----------------------------------------------------------------------
if verbose, fprintf('Step 1: Forward SIR solve (t=0..%g days)...\n', p.T); end

y0_fwd  = [p.S0; p.I0; p.R0_ic];
f_fwd   = @(t,y) sir_model(t, y, p.k, p.beta, p.tau, p.L);
[t_fwd, Y_fwd] = ode45(f_fwd, [0, p.T], y0_fwd, ode_opts);

if verbose
    [I_pk, pk_idx] = max(Y_fwd(:,2));
    fprintf('  Peak I = %.2f at t = %.1f days\n', I_pk, t_fwd(pk_idx));
end

%% -----------------------------------------------------------------------
%% STEP 2: Build dense interpolants for backward pass
%% -----------------------------------------------------------------------
if verbose, fprintf('Step 2: Building interpolants...\n'); end

S_fn = griddedInterpolant(t_fwd, Y_fwd(:,1), 'pchip');
I_fn = griddedInterpolant(t_fwd, Y_fwd(:,2), 'pchip');
R_fn = griddedInterpolant(t_fwd, Y_fwd(:,3), 'pchip');

%% -----------------------------------------------------------------------
%% STEP 3: Backward adjoint solve
%%   Terminal condition: lam(T) = 0 (no terminal cost, J = int I dt)
%% -----------------------------------------------------------------------
if verbose, fprintf('Step 3: Backward adjoint solve (t=%g..0)...\n', p.T); end

lam_T   = [0; 0; 0];
f_adj   = @(t,lam) sir_adjoint_rhs(t, lam, S_fn, I_fn, R_fn, ...
                                    p.k, p.beta, p.tau, p.L);
[t_adj, LAM] = ode45(f_adj, [p.T, 0], lam_T, ode_opts);

%% -----------------------------------------------------------------------
%% STEP 4: Compute sensitivity integrals
%%   SI_j = -integral_0^T  lambda(t)^T * (dF/dp_j)(t)  dt
%% -----------------------------------------------------------------------
if verbose, fprintf('Step 4: Computing sensitivity integrals...\n'); end

% Interpolate adjoint onto forward time grid for numerical integration
lam_S_fn = griddedInterpolant(flip(t_adj), flip(LAM(:,1)), 'pchip');
lam_I_fn = griddedInterpolant(flip(t_adj), flip(LAM(:,2)), 'pchip');

SI_adj = zeros(1, 4);
p_nom  = [p.k, p.beta, p.tau, p.L];

% Evaluate integrands on the forward time grid
S_vec = Y_fwd(:,1);
I_vec = Y_fwd(:,2);
N_val = p.S0 + p.I0 + p.R0_ic;  % constant population
lam_S = lam_S_fn(t_fwd);
lam_I = lam_I_fn(t_fwd);

% dF/dp_j vectors at each time point (only S and I components matter
% since lam_R contributes through gamma/mu terms)
integrand_k    = -lam_S .* (p.beta .* S_vec .* I_vec / N_val) + ...
                  lam_I .* (p.beta .* S_vec .* I_vec / N_val);
integrand_beta = -lam_S .* (p.k   .* S_vec .* I_vec / N_val) + ...
                  lam_I .* (p.k   .* S_vec .* I_vec / N_val);
integrand_tau  =  lam_I .* (I_vec / p.tau^2);    % from dF_I/dtau = I/tau^2
integrand_L    =  lam_I .* (I_vec / p.L^2);      % from dF_I/dL   = I/L^2

% Numerical integration (trapezoid rule on ode45 output)
raw_SI = [-trapz(t_fwd, integrand_k),   ...
          -trapz(t_fwd, integrand_beta), ...
          -trapz(t_fwd, integrand_tau),  ...
          -trapz(t_fwd, integrand_L)];

% Normalize: SI_j = (p_j / J) * raw_SI_j  where J = integral(I, 0, T)
J_nom = trapz(t_fwd, I_vec);
SI_adj = (p_nom / J_nom) .* raw_SI;

if verbose
    fprintf('  J = integral(I, 0, T) = %.4f\n', J_nom);
    param_names = {'k','beta','tau','L'};
    for j = 1:4
        fprintf('  SI_%s(J) = %8.4f\n', param_names{j}, SI_adj(j));
    end
end

%% -----------------------------------------------------------------------
%% STEP 5 (optional): Verify against FSE
%% -----------------------------------------------------------------------
if verify_fse
    if verbose, fprintf('Step 5: FSE verification...\n'); end
    
    % Reuse COMPUTE_TIME_SI to get FSE-based time-averaged SI
    % For J = int_0^T I dt, SI_j(J) via adjoint should match:
    %   a weighted integral of the time-dependent FSE SI
    [SI_fse_t, ~, ~] = compute_time_si(p, 2);  % QOI = I(t)
    % Weighted average: SI_j(J) = integral(SI_j^I * I) / J
    for j = 1:4
        si_j    = SI_fse_t(:,j);
        valid   = ~isnan(si_j);
        si_wtd  = trapz(t_fwd(valid), si_j(valid) .* I_vec(valid)) / J_nom;
        if verbose
            fprintf('  FSE weighted SI_%s = %8.4f  |  Adjoint = %8.4f  |  diff = %.2e\n', ...
                    {'k','beta','tau','L'}{j}, si_wtd, SI_adj(j), abs(si_wtd - SI_adj(j)));
        end
    end
end

%% -----------------------------------------------------------------------
%% STEP 6 (optional): Figure — lambda_I(t) alongside I(t) (Figure 6.4)
%% -----------------------------------------------------------------------
if do_plot
    h_fig = figure();
    set(h_fig,'Units','inches','Position',[1 1 8 3.5]);
    
    t_adj_flip = flip(t_adj);
    lam_I_plot = flip(LAM(:,2));
    
    subplot(1,2,1);
    yyaxis left;
    plot(t_fwd, I_vec/max(I_vec), 'r-', 'LineWidth', 1.8); hold on;
    ylabel('$I(t)/I_{\max}$','Interpreter','latex');
    yyaxis right;
    plot(t_adj_flip, lam_I_plot, 'b--', 'LineWidth', 1.8);
    ylabel('$\lambda_I(t)$','Interpreter','latex');
    xlabel('Time (days)','Interpreter','latex');
    title('Forward $I(t)$ and adjoint $\lambda_I(t)$','Interpreter','latex');
    legend({'$I(t)/I_{\max}$','$\lambda_I(t)$'},'Interpreter','latex','Location','best');
    grid on; xlim([0 p.T]);
    
    subplot(1,2,2);
    plot(t_adj_flip, flip(LAM(:,1)), 'b-', ...
         t_adj_flip, lam_I_plot, 'r--', ...
         t_adj_flip, flip(LAM(:,3)), 'g:', 'LineWidth', 1.6);
    xlabel('Time (days)','Interpreter','latex');
    ylabel('Adjoint variables','Interpreter','latex');
    title('All adjoint variables','Interpreter','latex');
    legend({'$\lambda_S(t)$','$\lambda_I(t)$','$\lambda_R(t)$'}, ...
           'Interpreter','latex','Location','best');
    grid on; xlim([0 p.T]);
    
    sgtitle(sprintf('Adjoint solution: $k=%g$, $\\beta=%g$, $\\tau=%g$', ...
                    p.k, p.beta, p.tau), 'Interpreter','latex');
    
    if ~isempty(save_pdf)
        exportgraphics(h_fig, save_pdf, 'ContentType','vector');
        fprintf('Figure saved to %s\n', save_pdf);
    end
end
end

function val = getfield_default(s, field, default)
if isfield(s,field), val = s.(field); else, val = default; end
end
