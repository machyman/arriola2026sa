function p = sir_nominal()
%SIR_NOMINAL  Canonical nominal parameter struct for the book's SIR model.
%   Returns the single, authoritative set of nominal parameter values used
%   throughout "Foundations of Sensitivity Analysis: Theory, Computation,
%   and Applications" (Arriola & Hyman, SIAM 2026).  Every script and function in
%   this repository that needs nominal values should call SIR_NOMINAL
%   rather than hard-coding numbers.
%
%   p = SIR_NOMINAL() returns a struct with fields:
%
%   Outputs:
%       p - struct with fields:
%           .k     - average number of contacts per person per day   [5]
%           .beta  - transmission probability per contact             [0.06]
%           .tau   - mean infectious period (days)                    [7]
%           .L     - mean lifespan (days)                             [10000]
%           .N     - total population                                 [1000]
%           .S0    - initial susceptible count                        [999]
%           .I0    - initial infectious count                         [1]
%           .R0_ic - initial recovered count                          [0]
%           .T     - simulation horizon (days)                        [90]
%           .R0    - basic reproduction number k*beta*tau             [2.1]
%
%   Notes:
%       gamma = 1/tau  is the recovery rate (day^-1).
%       mu    = 1/L    is the background mortality rate (day^-1).
%       The force of infection is lambda = k*beta*I/N.
%       R0 = k * beta * tau = 5 * 0.06 * 7 = 2.1 > 1 (endemic regime).
%
%   Example:
%       p = sir_nominal();
%       fprintf('R0 = %.2f\n', p.R0);
%
%   See also: SIR_MODEL, RUN_SIR_EXAMPLE

%   Reference: Arriola & Hyman, "Foundations of Sensitivity Analysis:
%   Theory, Computation, and Applications", SIAM, 2026.  Parameters defined in Ch.2-4.

p.k     = 5;           % contacts per person per day
p.beta  = 0.06;        % transmission probability per contact
p.tau   = 7;           % mean infectious period (days)
p.L     = 10000;       % mean lifespan (days)

p.N     = 1000;        % total (constant) population
p.S0    = 999;         % initial susceptibles
p.I0    = 1;           % initial infectives
p.R0_ic = 0;           % initial recovered (R0 used for repr. number)

p.T     = 90;          % simulation horizon (days)

% Derived quantities (computed, not free parameters)
p.gamma = 1 / p.tau;   % recovery rate (day^-1)
p.mu    = 1 / p.L;     % background mortality rate (day^-1)
p.R0    = p.k * p.beta * p.tau;  % basic reproduction number (= 2.1)
end
