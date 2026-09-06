# Changelog

Changes to the companion materials in this repository: the Python notebooks, the
MATLAB library, and the compiled book and solutions manual in `docs/`.

Versions match the manuscript, so a change here can be traced to the draft it
accompanies. The full development history of the book itself is not recorded
here; earlier revisions of this file tracked manuscript sessions rather than
changes to these materials, and are preserved in the repository's Git history.

---

## v1_21_0 — 2026-09-05

Corrects errors in the companion code found in review and in the verification
work that followed. **If you ran the MATLAB adjoint or the Sobol routines from an
earlier revision, take this update.** Several of these changes alter computed
results, not just wording.

### MATLAB, adjoint

`sir_adjoint_rhs.m` now integrates the book's adjoint equation directly,
`-d(lam)/dt = J^T lam + grad_g`. It previously passed `grad_g - J'*lam`, and
`run_sir_adjoint.m` compensated with four leading minus signs in the sensitivity
integrals. The pair returned the right indices for the shipped example while
matching neither the adjoint equation nor the sensitivity formula in the text, so
any modified or extended use of it rested on an inconsistent convention. Both
files are corrected together.

### MATLAB, forward sensitivity

`sir_jacobian.m` returns to the constant-N form of the Jacobian given in the
book. `test_fse_adjoint.m` no longer asserts that the Jacobian columns sum to
zero: that identity belongs to a state-dependent-N convention the book does not
use, and the assertion is what kept the two in disagreement. It now compares
entrywise against the book's equation.

### MATLAB, global sensitivity analysis

`saltelli_sample.m` defaults to the quasi-Monte Carlo path, and
`run_global_sa_sir.m` uses `N = 2048` and engages that path at both call sites.
The text justifies a power-of-two sample size by the balance property of a
Sobol' sequence; the shipped default had been pseudo-random, so the
justification described a sampler the code never used.

### Python

`ch09_global_sa.ipynb` draws a genuine Sobol' sequence through
`scipy.stats.qmc.Sobol` rather than independent uniform samples, uses
`N = 2048`, and no longer carries stray editing text in its source.
`ch06_adjoint_odes.ipynb` ships with no stored outputs, and its
finite-difference cross-check now differences the full demographic model across
all four parameters rather than a closed SIR across three.

### Documents

Book and solutions manual refreshed to v1_21_0. The book is now typeset in
SIAM's book class, the format it is being prepared for, so its page count changes
from 204 to 257; the earlier figure was a letter-size proxy and not a change in
content. The solutions manual is 97 pages. The v1_19_1 PDFs were removed rather
than kept alongside, so that `docs/` holds one current copy of each.

**Contents:** 9 Python notebooks, 21 MATLAB files.
**Build status:** both volumes compile with no errors, no undefined references
and no undefined citations.

---

## v1_19_1 — 2026-08-25

The state of the repository before the release above. Nine Python notebooks, one
per chapter, each running end to end in Colab; a MATLAB library of 21 files
across `core`, `fse`, `adjoint`, `globalsa` and `tests`; and the compiled book
and solutions manual in `docs/`.

The repository was not updated at v1_20_0. The v1_21_0 release above carries the
changes from both revisions.

---

## Before v1_19_1

The repository was reorganised at v1_18_1 into the present
`software/{python,matlab}` layout. Entries before that point described the
writing of the book rather than changes to these materials and are not
reproduced here. They remain in the Git history.
