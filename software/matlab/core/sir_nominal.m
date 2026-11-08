function p = sir_nominal()
%SIR_NOMINAL  Canonical nominal parameter struct for the book's SIR model.
%   Returns the single, authoritative set of nominal parameter values used
%   throughout "Foundations of Sensitivity Analysis: From Local
%   to Global Sensitivity" (Arriola & Hyman, in preparation).  Every script and function in
%   this repository that needs nominal values should call SIR_NOMINAL
%   rather than hard-coding numbers.
%
%   p = SIR_NOMINAL() returns a struct with fields:
%
%   Outputs:
%       p - struct with fields:
%           .c     - average number of contacts per person per day   [5]
%           .beta  - transmission probability per contact             [0.06]
%           .tau_R - mean infectious period (days)                    [7]
%           .tau_m - mean residence time (days)                       [10000]
%           .N     - total population                                 [1000]
%           .S0    - initial susceptible count                        [999]
%           .I0    - initial infectious count                         [1]
%           .R0_ic - initial recovered count R(0), not R0             [0]
%           .T     - simulation horizon (days)                        [90]
%           .R0    - basic reproduction number c*beta/(gamma_R+nu_m) [2.0985]
%
%   Notes:
%       gamma_R = 1/tau_R is the recovery rate (day^-1).
%       nu_m    = 1/tau_m is the turnover rate (day^-1).
%       The force of infection is lambda = c*beta*I/N.
%       R0 = c*beta/(gamma_R+nu_m) = 2.0985 > 1 (endemic regime).
%
%   Example:
%       p = sir_nominal();
%       fprintf('R0 = %.2f\n', p.R0);
%
%   See also: SIR_MODEL, RUN_SIR_EXAMPLE

%   Reference: Arriola & Hyman, "Foundations of Sensitivity Analysis:
%   From Local to Global Sensitivity", in preparation.  Parameters defined in Ch.2-4.

p.c     = 5;           % contacts per person per day
p.beta  = 0.06;        % transmission probability per contact
p.tau_R = 7;           % mean infectious period (days)
p.tau_m = 10000;       % mean residence time (days)

p.N     = 1000;        % total (constant) population
p.S0    = 999;         % initial susceptibles
p.I0    = 1;           % initial infectives
p.R0_ic = 0;           % initial recovered count R(0); p.R0 below is the reproduction number

p.T     = 90;          % simulation horizon (days)

% Derived quantities (computed, not free parameters)
p.gamma_R = 1 / p.tau_R;   % recovery rate (day^-1)
p.nu_m    = 1 / p.tau_m;   % turnover rate (day^-1)
%% R0 for the DEMOGRAPHIC model that sir_model.m integrates.  The
%% no-demography form c*beta*tau_R = 2.1 differs by 0.07% at tau_m =
%% 10,000 days, but the library and the book both use the demographic
%% equations, so the stored value must match them.
p.R0    = p.c * p.beta / (p.gamma_R + p.nu_m);   % = 2.0985
end
