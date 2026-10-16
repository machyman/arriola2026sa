# Changelog

Changes to the companion materials in this repository: the Python notebooks, the
MATLAB library, and drafts of the book and its solutions manual in `docs/`.

Versions match the manuscript, so a change here can be traced to the draft it
accompanies. The full development history of the book itself is not recorded
here; earlier revisions of this file tracked manuscript sessions rather than
changes to these materials, and are preserved in the repository's Git history.

---

## v1_25_0 (2026-10-16)

Corrects errors found in a close reading of v1_24_0, in all nine chapters and in Appendices B to E, and
replaces both drafts in `docs/` with v1_25_0, stamped "Draft" on every page. Seven of the nine Python
notebooks in `software/python/` change with the text. The MATLAB library is unchanged in this release.

### Book draft
- **Counting solves.** Section 1.2 now states one convention, and Chapters 1 to 7 and the solutions follow
  it: the baseline solve always counts. Forward sensitivity analysis costs m + 1 solves for m parameters;
  the adjoint costs two solves for one quantity of interest and r + 1 for r. Table 5.1, Table 7.2 and the
  cost comparisons use one rule, the adjoint when m > r and forward sensitivities when m ≤ r. Headings
  that counted solves changed with it, for example "Two Solves Instead of Fifty-One" in Chapter 6.
- **Chapter 1.** The description of Figure 1.2 matches the figure. The self-check on the recovery period
  now gives an index of +1.0, since R0 is linear in τ_R. Example 1.1 is introduced as the example it is.
  The claim that every sensitivity method reduces to the normalized derivative is narrowed. The Preface
  no longer says that Chapter 1 has a laboratory.
- **Chapter 2.** Remark 2.3 no longer says I(t) reaches zero in finite time. The footnote on R0 with
  demography, the rate form of recovery, and the reading of negative indices for rates and durations are
  corrected.
- **Chapter 3.** The step-size workflow is retitled "Checking the Step with an Error Indicator": the
  forward and backward checks are one indicator, not two, and the rounding and truncation errors at the
  optimal step are stated correctly. The second-derivative example, the claim about correlated
  parameters, and the curvature note (q = √p: a 10% rise in p raises q by 4.88%, not 5%) are corrected.
- **Chapter 4.** "One linear solve per parameter" is limited to equilibrium outputs. The role of the
  Jacobian in explicit and implicit solvers, the normalization that equation (4.1) needs, and the
  accuracy of default solver tolerances are stated correctly. The two values of R0 compared for the
  time-dependent indices no longer behave "alike": the recovery-period index turns negative near day 62
  at the nominal value and stays positive at R0 = 5.
- **Chapter 5.** Section 5.5's model is a competition model, so the section is now "The Competitive
  Population" (it was "The Symbiotic Population"). Its forward problem is the nonlinear equilibrium
  condition; only the forward sensitivity equations are linear.
- **Chapter 6.** The integral of I(t) is infectious person-time. The functional g takes one argument list
  throughout. The second quantity of interest is S(T), a case the chapter's method covers. The vector
  adjoint carries its arrow in Figure 6.1 and the text.
- **Chapter 7.** The annuity example's operation counts follow one stated convention (Section 7.1.5): 6
  for the function, 33 for forward mode with three inputs, 21 for reverse mode. Reverse mode is counted
  as two passes. Table 7.2's caption, its decision rule and the gray-box infection rate are corrected.
- **Chapter 8.** A new Section 8.4.1, "What Is Differentiated Decides the Failure," gives one account of
  why local sensitivity analysis fails near thresholds and bifurcations: six cases, sorted by what is
  differentiated, each with what to compute instead. The Unifying Ideas, the conditioning rules, the
  meaning of small and near-zero indices, and the recommended procedure now agree with it.
- **Chapter 9.** PRCC is described as a partial correlation. The Jansen estimator is explained by the law
  of total variance. The sampler is named once: one scrambled Sobol' sequence, N a power of two. The worked
  example's 95% intervals now come from 32 independent scrambles; the row bootstrap is kept for IID
  samples. The variance estimate is the pooled variance of all 2N model runs, as computed. Figure 9.1's
  caption, Table 9.3's claims, the finite-difference cost 2m + 1, and Exercises 9.1 and 9.9 are corrected.
- **Appendices.** B.3, C.1.2 and D.4 agree with Section 8.4.1. In D.4 a period-doubling needs a multiplier
  through -1. Appendix E's linear program has new data, so the indices sum to 1 by strong duality
  (z* = 1715), and its exercise statement and answer agree.
- **Notation and glossary.** The note on λ and the scope of N_v and N_h are corrected; the glossary's
  bifurcation entry agrees with Section 8.4.1.

### Solutions manual
- Every solution affected by the corrections above follows the corrected text, including the solve
  counts, the operation counts of Exercises 7.1 and 7.5, the answers to Exercises 8.2 to 8.6, and the
  Chapter 9 sampler and intervals. The chapter summaries agree.

### Notebooks
- Chapters 1 and 5: the cost figures and solve counts follow the book's convention. Chapter 1 also checks
  the corrected self-check and Example 1.1.
- Chapter 3: checks the curvature note's 4.88%.
- Chapter 4: one check also cites a sentence the text added; a guard's tolerance is named. No computation
  changes.
- Chapter 7: computes the operation counts under the stated convention, plots passes rather than
  operations, and checks Appendix E's exercise with z* = 1715.
- Chapter 8: new checks of the recovery-rate index with demography and of Appendix C's eigenvalue
  example.
- Chapter 9: computes the worked example's intervals from 32 independent scrambles and keeps the
  bootstrap as the comparison.

## v1_24_0 (2026-10-11)

Adds the solutions manual to `docs/`, as a draft stamped on every page, and replaces the book draft with v1_24_0.
The notebooks and the MATLAB library are unchanged in this release.

### Solutions manual
- `docs/solutions_manual_v1_24_0.pdf` gives a worked solution to every exercise in the book. It is written for
  self-study as much as for use as an instructor's key, and it carries the same version as the book draft.

### Book draft
- The Preface names the solutions manual among the materials hosted here.
- To the Instructor notes that the worked solutions are public, so an exercise used for grading is best varied
  from its printed form.

## v1_23_0 (2026-10-11)

Replaces the book draft in `docs/` with v1_23_0, stamped "Draft" on every page, and updates six of the
nine Python notebooks in `software/python/`. The MATLAB library is unchanged in this release. This
release also carries the changes of v1_22_3 and v1_22_4, which were not posted on their own.

### Book draft
- Chapter 7 has a new figure, Figure 7.1: the computation graph of the annuity function in Section 7.1,
  drawn once for forward mode, one pass per input, and once for reverse mode, one backward pass for all
  three inputs. Its generator checks every derivative it draws before it writes the figure.
- Exercises 9.3 and 9.5 now state their parameter ranges as plus or minus 50 percent about the nominal
  values (v1_22_4).
- The Preface's statement on the use of generative AI tools now ties the reader's own check to the
  companion notebooks, which readers can run for themselves (v1_22_3).

### Notebooks
- Nine cells in the Chapter 1, 2, 3, 4 and 9 notebooks have new descriptive IDs, such as
  `ch01-printed-numbers` and `ch09-bootstrap-example`. Colab and GitHub do not display cell IDs.
- Two failure messages are reworded, in Chapter 4 (Test 6) and Chapter 5. They print only if a check
  fails.
- No computation changes; every check and every printed result is as in v1_22_2.

---

## v1_22_2 (2026-10-08)

Replaces the book draft in `docs/` with v1_22_2, stamped "Draft" on every page, and updates the nine
Python notebooks in `software/python/`. The MATLAB library is unchanged in this release.

### Book draft
- The Preface's statement on the use of generative AI tools, and the paragraph on the companion code in
  Chapter 1, now describe more precisely how the numbers the book prints are verified.

### Notebooks
- Each notebook gains checks of the numbers its chapter prints, at the printed precision. Across the nine
  notebooks, `assert` statements rise from 108 to 281.
- 190 checks end with a comment of the form `# book: FILE "TEXT"`. FILE is the LaTeX source of a chapter
  or appendix, and TEXT is source text from the line whose printed value the check reproduces, so each
  check can be traced to the sentence it supports.
- Chapter 9 gains a cell that reproduces the worked example of §9.5.1: the SIR model with three
  parameters c, beta and tau_R, a Saltelli design with N = 256, the Jansen estimators and 100 bootstrap
  resamples. Since v1_22_0 the book prints this cell's output.

## v1_22_1 (2026-10-08)

Replaces the book draft in `docs/` with v1_22_1, stamped "Draft" on every page. The notebooks and the
MATLAB library are unchanged in this release.

### Book draft
- Eight equation references are now generated by LaTeX instead of typed. Six had pointed at the wrong
  equation after earlier renumbering, in Chapters 5 and 6 and in Appendices B and E.
- Chapter 8: the range from e^-2 to e^2 is a factor of about 55 (e^4 = 54.6), not 53.
- Chapter 5: 51 solves against 2 is a factor of about 25.
- Figure 3.1 and the time-dependent index figure in Chapter 4: values set by floating-point rounding are
  now given as orders of magnitude, since their digits depend on the machine.
- Appendix A: the norm of f is 0.658 and the Cauchy-Schwarz bound 0.465 (printed as 0.657 and 0.464).

## v1_22_0 (2026-10-05)

Replaces the book draft in `docs/` with v1_22_0, stamped "Draft" on every page like its
predecessor. The notebooks and the MATLAB library are unchanged in this release.

### Book draft
- §9.5.1, the worked example on bootstrap confidence intervals: the third parameter is now the
  infectious period τ_R rather than the recovery rate, so the three first-order indices are equal,
  as the text says. Every number in the example was regenerated.
- One exercise names its section by reference instead of by number. It prints the same.

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
