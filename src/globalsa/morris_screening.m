function [mu_star, sigma, EE, h_fig] = morris_screening(f, p_nom, lb, ub, ...
                                                          n_traj, p_levels, options)
%MORRIS_SCREENING  Morris screening via elementary effects.
%   Computes the Morris sensitivity measures mu* and sigma for each
%   parameter using r random one-at-a-time trajectories through the
%   parameter space (Chapter 9, Arriola & Hyman, eq. 9.15-9.16).
%
%   Morris measures:
%       EE_j(x) = [f(x + Delta*e_j) - f(x)] / Delta  (elementary effect)
%       mu*_j   = mean of |EE_j| over r trajectories (robust mean)
%       sigma_j = std  of  EE_j  over r trajectories (nonlinearity flag)
%
%   [MU_STAR, SIGMA, EE, H_FIG] = MORRIS_SCREENING(F, P_NOM, LB, UB,
%   N_TRAJ, P_LEVELS, OPTIONS) runs the full Morris analysis.
%
%   Inputs:
%       f        - model function handle: f(p) -> scalar
%       p_nom    - 1-by-m nominal parameter vector (for reference only)
%       lb       - 1-by-m lower bounds
%       ub       - 1-by-m upper bounds
%       n_traj   - number of trajectories r [default: 10]
%       p_levels - number of levels in the Morris grid p [default: 4]
%       options  - (optional) struct:
%           .param_names : m-cell of parameter name strings
%           .plot        : generate diagnostic plot [default: true]
%           .verbose     : print progress [default: false]
%
%   Outputs:
%       mu_star - 1-by-m vector of mean absolute EE (mu* measure)
%       sigma   - 1-by-m vector of standard deviation of EE
%       EE      - n_traj-by-m matrix of all elementary effects
%       h_fig   - figure handle ([] if options.plot = false)
%
%   Interpretation of diagnostic plot (mu* vs sigma):
%       Bottom-left  (small mu*, small sigma): negligible parameter
%       Right        (large mu*, small sigma): important, linear effect
%       Upper-right  (large mu*, large sigma): important, nonlinear/interaction
%
%   Example:
%       p = sir_nominal();
%       R0_fn = @(pv) pv(1)*pv(2)*pv(3);  % R0 = k*beta*tau
%       lb = 0.5*[p.k, p.beta, p.tau];
%       ub = 2.0*[p.k, p.beta, p.tau];
%       [mu_star, sigma] = morris_screening(R0_fn, [p.k,p.beta,p.tau], ...
%                                           lb, ub, 20, 4);
%
%   Reference: Morris, M.D. (1991). "Factorial sampling plans for
%   preliminary computational experiments."  Technometrics 33(2):161-174.
%   Campolongo, F. et al. (2007). "An effective screening design."
%   Environmental Modelling & Software 22(10):1509-1518.
%   See also: SOBOL_JANSEN, LHS_SAMPLE, SALTELLI_SAMPLE

%% --- Defaults ----------------------------------------------------------
if nargin < 5 || isempty(n_traj),   n_traj   = 10; end
if nargin < 6 || isempty(p_levels), p_levels = 4;  end
if nargin < 7 || isempty(options),  options  = struct(); end

param_names = getfield_default(options, 'param_names', {});
do_plot     = getfield_default(options, 'plot',        true);
verbose     = getfield_default(options, 'verbose',     false);

%% --- Input validation --------------------------------------------------
lb = lb(:)';  ub = ub(:)';  p_nom = p_nom(:)';
m = numel(lb);
if numel(ub) ~= m || numel(p_nom) ~= m
    error('morris_screening:DimensionMismatch', ...
          'lb, ub, and p_nom must all have the same length.');
end
if any(lb >= ub)
    error('morris_screening:InvalidBounds', ...
          'Each lb(j) must be strictly less than ub(j).');
end
if isempty(param_names)
    param_names = arrayfun(@(j) sprintf('p_%d',j), 1:m, 'UniformOutput',false);
end

%% --- Morris step size: Delta = p/(2*(p-1)) where p = p_levels ---------
Delta  = p_levels / (2*(p_levels - 1));

%% --- Preallocate elementary effects matrix ----------------------------
EE = zeros(n_traj, m);

%% --- Generate trajectories and compute EE -----------------------------
for r = 1:n_traj
    if verbose, fprintf('  Trajectory %d/%d\n', r, n_traj); end
    
    % Random starting point on the Morris grid (multiples of 1/(p-1))
    grid_step = 1 / (p_levels - 1);
    x0_unit = grid_step * randi(p_levels - 1, 1, m);  % in [0, 1-Delta]
    % Ensure x0 + Delta <= 1
    for j = 1:m
        if x0_unit(j) + Delta > 1
            x0_unit(j) = x0_unit(j) - Delta;
        end
    end
    
    % Random permutation of parameters for this trajectory
    perm_j = randperm(m);
    
    % Scale to [lb, ub]
    x_unit = x0_unit;
    x_phys = lb + x_unit .* (ub - lb);
    
    f_current = f(x_phys);
    
    for k = 1:m
        j = perm_j(k);
        
        % Perturb parameter j by +Delta (in unit space) then scale
        x_unit_p       = x_unit;
        x_unit_p(j)    = x_unit(j) + Delta;
        x_phys_p       = lb + x_unit_p .* (ub - lb);
        f_perturbed    = f(x_phys_p);
        
        % Elementary effect for parameter j at this trajectory point
        delta_phys     = x_phys_p(j) - x_phys(j);
        EE(r, j)       = (f_perturbed - f_current) / delta_phys;
        
        % Move to perturbed point for next parameter
        x_unit    = x_unit_p;
        x_phys    = x_phys_p;
        f_current = f_perturbed;
    end
end

%% --- Compute Morris measures ------------------------------------------
mu_star = mean(abs(EE), 1);   % robust mean (mu*)
sigma   = std(EE, 0, 1);       % standard deviation

%% --- Print summary table ----------------------------------------------
fprintf('\nMorris Screening Results (%d trajectories, p=%d levels):\n', ...
        n_traj, p_levels);
fprintf('  %-12s %10s %10s  Classification\n', 'Parameter', 'mu*', 'sigma');
fprintf('  %s\n', repmat('-',1,55));

mu_thresh = 0.1 * max(mu_star);  % relative threshold
for j = 1:m
    if mu_star(j) < mu_thresh
        class_str = 'Negligible';
    elseif sigma(j) < 0.5 * mu_star(j)
        class_str = 'Important, linear';
    else
        class_str = 'Important, nonlinear/interacting';
    end
    fprintf('  %-12s %10.4f %10.4f  %s\n', ...
            param_names{j}, mu_star(j), sigma(j), class_str);
end
fprintf('\n');

%% --- Diagnostic plot: mu* vs sigma -----------------------------------
h_fig = [];
if do_plot
    h_fig = figure();
    set(h_fig, 'Units','inches','Position',[1 1 5.5 4.5]);
    
    scatter(mu_star, sigma, 80, 'b', 'filled', 'MarkerEdgeColor','k','LineWidth',0.5);
    hold on;
    
    % Label each point
    offset = 0.02 * max(max(mu_star), max(sigma));
    for j = 1:m
        text(mu_star(j) + offset, sigma(j), param_names{j}, ...
             'Interpreter','latex', 'FontSize',10, 'HorizontalAlignment','left');
    end
    
    % Threshold lines
    yline(0, 'k:', 'LineWidth', 0.8);
    xline(0, 'k:', 'LineWidth', 0.8);
    
    xlabel('$\mu^*$ (mean $|EE|$)', 'Interpreter','latex', 'FontSize',12);
    ylabel('$\sigma$ (std of $EE$)',  'Interpreter','latex', 'FontSize',12);
    title(sprintf('Morris Screening: %d trajectories', n_traj), ...
          'Interpreter','latex', 'FontSize',12);
    
    % Annotation regions
    xl = xlim(); yl = ylim();
    text(0.05*xl(2), 0.92*yl(2), 'Nonlinear/Interacting', ...
         'Color',[0.5 0.5 0.5], 'FontSize',8, 'Interpreter','latex');
    text(0.55*xl(2), 0.10*yl(2), 'Important, linear', ...
         'Color',[0.5 0.5 0.5], 'FontSize',8, 'Interpreter','latex');
    text(0.02*xl(2), 0.10*yl(2), 'Negligible', ...
         'Color',[0.5 0.5 0.5], 'FontSize',8, 'Interpreter','latex');
    
    grid on; box on;
end
end

%% -----------------------------------------------------------------------
function val = getfield_default(s, field, default)
if isfield(s,field), val = s.(field); else, val = default; end
end
