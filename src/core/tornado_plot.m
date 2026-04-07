function h = tornado_plot(SI_values, labels, QOI_name, options)
%TORNADO_PLOT  Publication-quality tornado plot of sensitivity indices.
%   Produces the horizontal bar chart used throughout Chapter 2 of
%   Arriola & Hyman.  Bars are sorted by absolute SI value (largest at
%   top), positive SI values extend right (red), negative extend left
%   (blue), and a vertical reference line marks SI = 0.
%
%   H = TORNADO_PLOT(SI_VALUES, LABELS, QOI_NAME) creates the plot and
%   returns a handle to the figure.
%
%   H = TORNADO_PLOT(SI_VALUES, LABELS, QOI_NAME, OPTIONS) uses
%   user-supplied display options.
%
%   Inputs:
%       SI_values - n-vector of sensitivity indices S_{p_i}^q
%       labels    - n-element cell array of POI name strings
%                   (LaTeX allowed, e.g., {'$k$','$\beta$','$\tau$'})
%       QOI_name  - string identifying the QOI (for axis/title label)
%       options   - (optional) struct with fields:
%           .fig_num    : figure number [default: new figure]
%           .bar_color  : [pos_color, neg_color] as RGB pairs
%                         [default: [0.8 0.2 0.2; 0.2 0.4 0.8]]
%           .font_size  : axis font size [default: 12]
%           .x_lim      : manual x-axis limits [default: auto ±1.1*max|SI|]
%           .title_str  : override title string [default: auto]
%           .show_values: annotate bars with SI values [default: true]
%
%   Outputs:
%       h - handle to the created figure
%
%   Example:
%       p      = sir_nominal();
%       SI     = [1; 1; -1; 0];   % S_k, S_beta, S_tau, S_L for R0
%       labels = {'$k$','$\beta$','$\tau$','$L$'};
%       h = tornado_plot(SI, labels, 'R_0');
%
%   Algorithm:
%       Sort parameters by |SI| descending.  Draw horizontal bars
%       extending from 0.  Annotate with numeric SI values.
%       Uses MATLAB's BARH with proper color coding.
%
%   See also: SENSITIVITY_JACOBIAN, SENSITIVITY_INDEX

%% --- Default options ---------------------------------------------------
if nargin < 4 || isempty(options), options = struct(); end
pos_color   = getfield_default(options, 'bar_color', ...
                [0.80 0.20 0.20; 0.20 0.40 0.80]);
font_size   = getfield_default(options, 'font_size', 12);
x_lim       = getfield_default(options, 'x_lim', []);
title_str   = getfield_default(options, 'title_str', '');
show_values = getfield_default(options, 'show_values', true);
fig_num     = getfield_default(options, 'fig_num', []);

%% --- Input validation --------------------------------------------------
validateattributes(SI_values, {'numeric'}, {'vector','finite'}, ...
                   'tornado_plot', 'SI_values');
SI_values = SI_values(:);
n = length(SI_values);

if ~iscell(labels) || numel(labels) ~= n
    error('tornado_plot:LabelMismatch', ...
          'LABELS must be a cell array with %d elements.', n);
end

%% --- Sort by |SI| descending (largest at top after flipping) -----------
[~, idx]     = sort(abs(SI_values), 'ascend');   % ascending -> top = largest after flip
SI_sorted    = SI_values(idx);
labels_sorted = labels(idx);

%% --- Create figure -----------------------------------------------------
if isempty(fig_num)
    h = figure();
else
    h = figure(fig_num); clf;
end
set(h, 'Units','inches','Position',[1 1 6 max(2, 0.45*n + 1)]);

%% --- Draw bars ---------------------------------------------------------
ax = axes('Parent', h);
hold(ax, 'on');

y_pos = 1:n;
for i = 1:n
    si = SI_sorted(i);
    if si >= 0
        c = pos_color(1,:);
    else
        c = pos_color(2,:);
    end
    barh(ax, y_pos(i), si, 0.6, 'FaceColor', c, 'EdgeColor', 'k', ...
         'LineWidth', 0.5);
end

%% --- Reference line at SI = 0 ------------------------------------------
xline(ax, 0, 'k-', 'LineWidth', 1.2);

%% --- Axes formatting ---------------------------------------------------
set(ax, 'YTick', y_pos, 'YTickLabel', labels_sorted, ...
        'FontSize', font_size, 'TickLabelInterpreter', 'latex');
xlabel(ax, sprintf('Sensitivity index $S_p^{%s}$', QOI_name), ...
       'Interpreter', 'latex', 'FontSize', font_size);

if isempty(title_str)
    title_str = sprintf('Tornado plot: sensitivities of $%s$', QOI_name);
end
title(ax, title_str, 'Interpreter', 'latex', 'FontSize', font_size);

%% --- x-axis limits -----------------------------------------------------
if isempty(x_lim)
    max_abs = max(abs(SI_sorted));
    if max_abs < eps, max_abs = 1; end
    x_lim = [-1.15*max_abs, 1.15*max_abs];
end
xlim(ax, x_lim);
ylim(ax, [0.3, n + 0.7]);
box(ax, 'on');
grid(ax, 'on');

%% --- Annotate bar values -----------------------------------------------
if show_values
    offset = 0.03 * diff(x_lim);
    for i = 1:n
        si = SI_sorted(i);
        if si >= 0
            txt_x = si + offset;
            align = 'left';
        else
            txt_x = si - offset;
            align = 'right';
        end
        text(ax, txt_x, y_pos(i), sprintf('%.3f', si), ...
             'HorizontalAlignment', align, ...
             'VerticalAlignment',   'middle', ...
             'FontSize', font_size - 1, ...
             'Interpreter', 'latex');
    end
end

hold(ax, 'off');
end

%% -----------------------------------------------------------------------
function val = getfield_default(s, field, default)
if isfield(s, field), val = s.(field); else, val = default; end
end
