function h = plot_time_si(t, SI_t, Y_state, p, options)
%PLOT_TIME_SI  Publication figure: time-dependent SI curves alongside I(t).
%   Produces the replacement for Figure 4.3 ("Schematic of time-dependent
%   sensitivity indices") with actual computed values at the nominal
%   parameters from Arriola & Hyman, SIAM 2026.
%
%   H = PLOT_TIME_SI(T, SI_T, Y_STATE, P) creates the figure.
%   H = PLOT_TIME_SI(T, SI_T, Y_STATE, P, OPTIONS) uses extra options.
%
%   Inputs:
%       t       - time vector (n_t x 1, days)
%       SI_t    - n_t x 4 sensitivity index matrix [SI_k, SI_beta, SI_tau, SI_L]
%       Y_state - n_t x 3 state matrix [S, I, R]
%       p       - parameter struct from SIR_NOMINAL
%       options - (optional) struct:
%           .save_pdf : filename to save PDF [default: '' (no save)]
%           .fig_num  : figure number [default: new figure]
%
%   Outputs:
%       h - figure handle
%
%   Example:
%       p = sir_nominal();
%       [SI_t, t, Y] = compute_time_si(p, 2);
%       h = plot_time_si(t, SI_t, Y, p);
%
%   See also: COMPUTE_TIME_SI, SIR_NOMINAL

if nargin < 5, options = struct(); end
save_pdf = getfield_default(options, 'save_pdf', '');
fig_num  = getfield_default(options, 'fig_num', []);

%% --- Figure setup -------------------------------------------------------
if isempty(fig_num), h = figure(); else, h = figure(fig_num); clf; end
set(h, 'Units','inches','Position',[1 1 9 4]);

colors = [0.8 0.1 0.1;   % k  - red
          0.1 0.5 0.8;   % beta - blue
          0.1 0.7 0.2;   % tau - green
          0.6 0.3 0.8];  % L   - purple
styles = {'-','--','-.',':'};
labels = {'$S_k^I(t)$','$S_\beta^I(t)$','$S_\tau^I(t)$','$S_L^I(t)$'};

I = Y_state(:,2);

%% --- Left panel: SI curves ---------------------------------------------
ax1 = subplot(1,2,1);
hold(ax1,'on');
for j = 1:4
    si = SI_t(:,j);
    valid = ~isnan(si);
    plot(ax1, t(valid), si(valid), styles{j}, ...
         'Color', colors(j,:), 'LineWidth', 1.8);
end
yline(ax1, 0, 'k-', 'LineWidth', 0.8);
hold(ax1,'off');
xlabel(ax1, 'Time (days)', 'Interpreter','latex');
ylabel(ax1, 'Sensitivity index', 'Interpreter','latex');
title(ax1, 'Time-dependent SI for $I(t)$', 'Interpreter','latex');
legend(ax1, labels, 'Interpreter','latex', 'Location','best', 'FontSize',9);
grid(ax1,'on'); box(ax1,'on');
xlim(ax1, [0 p.T]);

%% --- Right panel: SI curves overlaid with epidemic ---------------------
ax2 = subplot(1,2,2);
yyaxis(ax2,'left');
for j = 1:4
    si = SI_t(:,j);
    valid = ~isnan(si);
    plot(ax2, t(valid), si(valid), styles{j}, ...
         'Color', colors(j,:), 'LineWidth', 1.8); hold(ax2,'on');
end
yline(ax2, 0, 'k-', 'LineWidth', 0.8);
ylabel(ax2, 'Sensitivity index', 'Interpreter','latex');

yyaxis(ax2,'right');
plot(ax2, t, I/max(I), 'k-', 'LineWidth', 1.0);
ylabel(ax2, '$I(t)/I_{\max}$ (normalized)', 'Interpreter','latex');

xlabel(ax2, 'Time (days)', 'Interpreter','latex');
title(ax2, 'SI curves vs epidemic', 'Interpreter','latex');
grid(ax2,'on'); box(ax2,'on');
xlim(ax2, [0 p.T]);

%% --- Overall title ------------------------------------------------------
param_str = sprintf('$k=%g$, $\\beta=%g$, $\\tau=%g$, $L=%g$, $R_0=%.1f$', ...
                    p.k, p.beta, p.tau, p.L, p.R0);
sgtitle(h, param_str, 'Interpreter','latex', 'FontSize',11);

%% --- Save if requested -------------------------------------------------
if ~isempty(save_pdf)
    exportgraphics(h, save_pdf, 'ContentType','vector');
    fprintf('Figure saved to %s\n', save_pdf);
end
end

function val = getfield_default(s, field, default)
if isfield(s,field), val = s.(field); else, val = default; end
end
