# Changelog

Changes to the companion materials in this repository: the Python notebooks, the
MATLAB library, and a draft of the book in `docs/`.

Versions match the manuscript, so a change here can be traced to the draft it
accompanies. The full development history of the book itself is not recorded
here; earlier revisions of this file tracked manuscript sessions rather than
changes to these materials, and are preserved in the repository's Git history.

---

## v1_21_5 (2026-09-25)

Brings five notebooks up to the current draft, replaces the book PDF with the current draft, removes
the solutions manual PDF, and corrects the README.
**If you ran `ch04_analytic_forward_sensitivity_analysis.ipynb` from an earlier revision, run it
again.** One of its changes alters a computed result.

### Notebooks
- `ch04_analytic_forward_sensitivity_analysis.ipynb`: the forward solve used to normalize the
  time-dependent sensitivity index omitted the demographic terms that the sensitivity solve
  includes. It now carries them, and the normalized curve changes slightly. A new verification
  cell checks the numbers Chapter 4 prints against closed forms.
- `ch02_local_sa.ipynb`: a second verification cell checks the worked examples in Sections 2.1,
  2.4.2, 2.4.4 and 2.4.5 at the precision the book prints them.
- `ch05_the_adjoint_in_linear_algebra.ipynb`: a new cell computes the competitive Lotka-Volterra
  equilibrium behind the verification table in Chapter 5 and checks it.
- `ch08_caveat_emptor.ipynb`: new checks on the Section 8.3 self-check (determinant, condition
  number, solution and sensitivity index).
- `ch09_global_sa.ipynb`: two new verification cells, one for the ANOVA worked example of
  Section 9.4.2 in exact rational arithmetic, one for the Morris walkthrough of Section 9.6.

The other four notebooks and the MATLAB library are unchanged.

### `docs/`
- The v1_21_0 book is replaced by the v1_21_5 draft, `sensitivity_analysis_book_v1_21_5.pdf`.
- The v1_21_0 solutions manual is removed. Both v1_21_0 PDFs carried errors since corrected.

### README and citation
- The README describes what the notebooks check in the book's terms. It no longer implies that a
  notebook which runs cleanly has confirmed every number in its chapter.
- Chapter titles match the book; notebook names link to the files.
- Removed: the note on planned ports and a dependency on `SALib` that no notebook has.
- The `docs/` description names the book draft, the only PDF now posted.
- The development-tools note is replaced by a summary of the book's declaration on the use of
  AI tools.
- `CITATION.cff` records version v1_21_5.

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
