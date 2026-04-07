# Foundations of Sensitivity Analysis: Theory, Computation, and Applications

**Authors:** Leon M. Arriola and James M. Hyman  
**Version:** v14 (2026-04-06) | **Pages:** 146 | **Errors:** 0

## Quick Start

```matlab
addpath(genpath('src'))
run_sir_example      % Ch2-3 demo
run_global_sa_sir    % Ch9 complete pipeline (~5-10 min)
```

## Repository Structure

```
src/core/       sir_nominal, sir_model, sensitivity_index,
                sensitivity_jacobian, tornado_plot, run_sir_example
src/fse/        sir_jacobian, sir_augmented, compute_time_si, plot_time_si
src/adjoint/    sir_adjoint_rhs, run_sir_adjoint
src/globalsa/   lhs_sample, saltelli_sample, sobol_jansen,
                compute_prcc, morris_screening, run_global_sa_sir
tests/          test_core (17), test_fse_adjoint (11), test_globalsa (17)
paper/          LaTeX source (compile with pdflatex + bibtex + pdflatex x2)
```

## Running Tests

```matlab
addpath(genpath('src'))
test_core; test_fse_adjoint; test_globalsa
```

## Requirements

- MATLAB R2019b+ (base)
- Statistics and ML Toolbox (recommended; fallbacks provided)

## Companion Volume

R. C. Smith, *Uncertainty Quantification*, SIAM, 2014.

© 2026 Arriola & Hyman. SIAM submission — pre-publication only.
