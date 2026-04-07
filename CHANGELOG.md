# Changelog — Foundations of Sensitivity Analysis: Theory, Computation, and Applications

All notable changes to this project are documented here.

## [v13] — 2026-04-06 — MREP v4 Pipeline Complete

### Fixed (Equations)
- `eq:carSI` (Ch4): Both car rental sensitivity index formulas were wrong. Corrected to $S_\alpha^{A^*} = \alpha/(2-\alpha-\beta)$ and $S_\alpha^{B^*} = -\alpha(1-\beta)/((1-\alpha)(2-\alpha-\beta))$. Verified by finite difference.
- `eq:totalSI` (Ch3): Total-derivative SI formula had a spurious $(p_j/p_i)$ factor inconsistent with the self-check answer. Corrected to $S_{p_i}^q|_\text{tot} = S_{p_i}^q|_\text{std} + \sum_j S_{p_j}^q \, c_{ij}$ with $c_{ij}$ defined as the proportional coupling coefficient.

### Fixed (Bibliography)
- `saltelli2019why`: Journal field corrected from *Reliability Engineering & System Safety* to *Environmental Modelling & Software* (vol. 114, pp. 29–39).
- `chen2018neural`: Annote field had copy-paste error listing Baydin et al. authors; corrected to Chen/Rubanova/Bettencourt/Duvenaud.
- Ch8 opener: "30 papers" corrected to "280 papers" (actual number reviewed in Saltelli 2019).

### Improved (Rigor)
- Theorem 4.1 proof expanded to SIAM monograph standard: full chain-rule justification, explicit statement of linearity argument, nonsingularity condition.
- Fredholm alternative cross-reference added from Ch8 bifurcation section to Appendix B §3.

### Improved (Structure)
- Preface: added paragraph previewing adjoint (Chs 5–7) and Caveat Emptor (Ch8); added positioning paragraph vs. Giles/Cao/Griewank; added Instructor's Guide note.
- Ch6/Ch7: All unifyingidea callbacks now explicitly name the idea by number.
- Ch9: Closing sentence added completing the student journey; final impact statement added.

### Improved (Content)
- Car rental (Ch4): Numerical interpretation added after eq:carSI ($\alpha=0.7,\beta=0.3 \to S=0.70$).
- Ch8: Multi-attractor limitation paragraph added (bistable models, local SA failure mode).
- Ch8: Fredholm alternative connection to FSE singularity at bifurcations made explicit.
- Ch9 PRCC: Scatter-plot-first advice added for checking monotonicity before applying PRCC.
- Ch6: Bridge sentence added before Lagrange derivation connecting to Ch5 strategy.

### Added (Coverage gaps)
- Ch3: Structural identifiability section — connects sensitivity to parameter identifiability; notes that equal SIs signal structural correlation; cites Smith §9.3.
- Ch9: Surrogate/emulator models section — Gaussian process and polynomial chaos context; connects to Smith Chs 12–13.
- Ch9: Bootstrap confidence intervals for Sobol indices — complete MATLAB implementation.
- Ch1: Functional/trajectory QOI scope note — explains why book focuses on scalar QOIs.

### Added (Accessibility)
- Ch5: New §5.1 "A Preview: The Same Answer, One Solve Instead of Fifty" — complete 2×2 worked example with $A=[[3,1],[1,2]]$, forward approach (2 solves), adjoint approach (1 solve + dot products), and self-check.
- Ch6: New warm-up subsection before Lagrange derivation — exponential decay $\dot{u}=-pu$, $J=u(T)$, full adjoint computed with numbers, answer verified against direct differentiation.

### Added (Smith UQ citations)
- Ch1 §1.4: Smith Chs 9–10 cited for graduate-level extensions.
- Ch1 UI1: Smith §9.1–9.2 cited for normalized-derivative framework.
- Ch3 identifiability: Smith §9.3 cited.
- Ch5 bridge: Smith §6.1 cited for parameter selection connection.
- Ch6 §6.7: Smith §9.4 cited for adjoint ODE implementation guidance.

### Style (SPRE)
- 1 AI-signature word removed ("crucial" → "central").
- 21 prose em-dashes converted to commas, semicolons, colons, or parentheses.
- 3 short itemized lists converted to prose (Ch7, Ch9 ×2).

## [v12] — 2026-04-06 — Baseline

Verified bibliography (46 entries, all field-checked). Prior structural improvements including unifying idea callbacks, accessibility additions (adjoint preview, identifiability, surrogates, bootstrap CI), and Ch9 closing material.

## [v14] — 2026-04-06 — Sessions 6-7: MATLAB Library, Solutions Manual, Mathematical Gaps

### Added (MATLAB Code Library — MLS v2.0)
- `src/core/`: sir_nominal, sir_model, sensitivity_index, sensitivity_jacobian, tornado_plot, run_sir_example
- `src/fse/`: sir_jacobian, sir_augmented, compute_time_si, plot_time_si (produces computed Fig 4.3)
- `src/adjoint/`: sir_adjoint_rhs, run_sir_adjoint (produces computed Fig 6.4)
- `src/globalsa/`: lhs_sample, saltelli_sample, sobol_jansen (with bootstrap CI), compute_prcc, morris_screening, run_global_sa_sir
- `tests/`: test_core (17 tests), test_fse_adjoint (11 tests), test_globalsa (17 tests)

### Added (Solutions Manual — 55 pages)
- Complete instructor's solutions for all 62 exercises across Chapters 1–9
- Full worked derivations for L3 exercises; model answers with grading rubrics for L5–L6
- MATLAB code snippets for computational exercises

### Fixed (Mathematical Gaps)
- **G1 (Appendix C):** Added Proposition and proof that y_k^T x_k ≠ 0 for distinct eigenvalues, citing Horn & Johnson Theorem 1.4.5. Added Horn & Johnson (2012) to bibliography.
- **G2 (Ch9 ANOVA):** Uniqueness of ANOVA decomposition now cites Sobol (2001) Theorem 1 and Saltelli et al. (2008) Appendix A, with orthogonality conditions stated.
- **G3 (Ch9 Jansen):** Added two-sentence convergence sketch: expectation identity showing near-unbiasedness, O(1/N) bias, citing Jansen (1999) Theorem 1.

### Added (New Content)
- **Ch8 §8.X "When SA Guides Data Collection":** ~2-page section completing the book's practical argument. Three-filter decision chain (identifiability, measurability, actionability); two-budget problem procedure; bridge to Smith UQ Chapters 7–8 and 11.

### Added (Preface)
- **Acknowledgments:** Thanks to Ralph C. Smith, course students, SIAM reviewers, and institutional support. Funding placeholder.
- **Dedication:** "To our students, past and future: May you always ask which parameters matter before you run the model."

### Updated (Manuscript Snippets)
- Ch3: sensitivity_jacobian verbatim block replaced with compact 5-line repository reference
- Ch9: sobol_jansen and lhs_sample verbatim blocks replaced with compact usage snippets

## [v15] — 2026-04-06 — Title Change

### Changed
- **Title updated** from "Sensitivity Analysis with Applications in Mathematical Modeling"
  to **"Foundations of Sensitivity Analysis: Theory, Computation, and Applications"**
- Updated in all 14 affected locations: LaTeX title block, PDF metadata (pdftitle, pdfsubject),
  CITATION.cff, README.md, CHANGELOG.md, all MATLAB docstring headers (sir_nominal, sir_model,
  run_sir_example, run_global_sa_sir), and solutions manual preamble.
- pdfsubject updated to include "Uncertainty Quantification" alongside "Sensitivity Analysis"
  and "Mathematical Modeling".

## [v1.1.0] — 2026-04-07 — RARP Reader Exercise and Stress-Test

### Reader-Augmented Review Protocol (RARP v1.0)

Conducted a full 9-chapter reader simulation using GPT-4o as Alex Chen
(third-year applied mathematics undergraduate), followed by stress-tests
with Gemini 2.0 Pro (×2), Grok 3, and DeepSeek-R1.

Total: 5 AI models, 20 cross-model confirmed findings, 0 errors remaining.

### Manuscript revisions from reader exercise (27 targeted changes)

**Factual corrections:**
- Ch2 §2.3: Changed S(t)→0 (biologically wrong) to I(t)→0 for SIR
- Ch3/4/7: Corrected n_p×n_q evaluation count to 2n_p+1 (cascading fix, 7 locations)

**Conceptual additions:**
- Ch1 §1.3: Added p² micro-example anchoring local-vs-global distinction
- Ch1 §1.1: Expanded POI definition to epistemic/aleatory/control taxonomy
- Ch5 §5.1: Added "What does v represent?" plain-language paragraph
- Ch6: Added linearity parallel (Thm 4.1 analog) and sign convention box
- Ch9 §9.3: Added "Why does unique ANOVA decomposition exist?" paragraph
- Ch9 §9.3: Added f=Q₁+Q₂+Q₁Q₂ concrete ANOVA worked example (Grok/DeepSeek finding)
- Ch8 §8.2: Added operational rule for when SI is too large to report as ranking

**QOI correlation treatment (Point 1):**
- Ch5: Added "A note on correlated QOIs" clarifying adjoint handles automatically
- Ch6 §6.4.4: Added "Multiple QOIs and correlated outputs" subsection

**POI taxonomy (Point 2):**
- Ch1 §1.1: Full three-category expansion with examples and interpretation guidance

**Pedagogical additions (11 maxims across 6 chapters):**
- Ch2, Ch5, Ch6, Ch9: Chapter-opening epigraphs (flushright italic)
- Ch4 §4.4: "Before improving the model..." section quote
- Ch3 §3.4: Tcolorbox callout on uncertainty vs importance
- Ch7 §7.4.4: Footnote on if-statements and smooth calculus
- Ch8: Centred maxim after Saltelli citation; closing sentence in §8.3
- Ch9 §9.1: Neighborhood/country transition; bridge closing sentence

**MATLAB lab improvements (7):**
- Symbolic Toolbox fallback (Ch2), save-as-function instruction (Ch2)
- State-vector layout table (Ch4), interpolation bolded note (Ch6)
- LU syntax explanation (Ch5), error-message hint (Ch3)
- Backpropagation skip-note (Ch5 §5.6) — confirmed by 4/5 models

**Other fixes:**
- Ch1 Fig 1.2 caption: defined λ(t) as sensitivity weights
- Ch6 opening: Added notation step-up warning (Gemini finding, confirmed by Grok)
- Ch5 QOI correlation note: Rewritten for clarity (DeepSeek finding)
- Preamble: Added tcolorbox package

### RARP protocol
- RARP v1.0 protocol document created (docs/RARP_v1.0_Reader_Augmented_Review_Protocol.md)
- Model routing established: GPT/Grok for full protocol; DeepSeek for math validation;
  Gemini for directional confirmation

### Final state
- 152 pages (was 142 at v1.0.0)
- 0 LaTeX errors, 0 warnings, 0 undefined references
- All 9 chapters validated by ≥2 independent AI models

## v1.2 — 2026-04-06

### Ch6 §6.3 — Physical analogies added to five-step Lagrange derivation
- One *Physical analogy* paragraph after each of Steps 1–5 (building-inspector/structural thread)
- Addresses Grok 3 top-priority pre-publication fix

### §5.6 — Backpropagation node-to-adjoint mapping
- Added explicit sentence: node vᵢ → eᵢ; λᵢ = ∂J/∂vᵢ

### Ch9 — Surrogate model paragraph expanded
- Added two sentences defining GP surrogate and polynomial chaos expansion concretely

### Ch5 — Shadow-price framing added to v-paragraph

### Preface — Two sentences removed
- Removed "The book is organized as a one-semester..." and "It forms Part 1 of a two-semester sequence..."

### Global — \POI / \QOI spacing fixed
- Added \usepackage{xspace}; all four macros updated — fixes spacing throughout all chapters

### Figure 1.2 — Geometry corrected
- Panel separation widened (6.8 → 7.6 units); boxes no longer overlap
- Dividing rule repositioned above all content
- Dashed λ(t) arc raised clear of box tops
- Sub-labels repositioned to prevent overlap

**Page count:** 152 → 154
**Compile status:** 0 errors, 0 warnings, 0 undefined references

## v1.3 — 2026-04-06

### Chapter maxims added (all 9 chapters)
- Ch1: "Sensitivity analysis begins when a model is forced to say what matters."
- Ch2: "A sensitivity index is a normalized derivative with a practical job." (added above existing epigraph)
- Ch3: "A derivative is useful only if you can compute it honestly."
- Ch4: "Differentiate the model, and the important parameters identify themselves."
- Ch5: Already present — no change.
- Ch6: "To understand the effect of an outcome, trace its influence backward through time." (added above existing epigraph)
- Ch7: "Reverse the calculation, and one output can speak about many inputs."
- Ch8: "Local sensitivity is a linear truth, and nature is rarely linear for long."
- Ch9: Already present — no change.

### Secondary callouts added (3 locations)
- Ch3 §U-curve: "Before improving the model, find out which knob actually moves the machine."
- Ch8 §When Global SA Is Needed: "Local SA studies the neighborhood. Global SA studies the country."
- Ch9 §Sigma-normalized bridge: same neighborhood/country line elevated from prose to italic callout

**Page count:** 154 (unchanged)
**Compile status:** 0 errors, 0 undefined references

## v1.7 — 2026-04-06

### Figure 1.2 — Complete redesign
- New design: tall central Model box in each panel; arrows pass THROUGH the Model
- Panel (a) Forward SA: p_j column on left, bold path through Model to QOI, faded arrows for other POIs
- Panel (b) Adjoint SA: one dashed arrow QOI→Model, multiple dashed arrows Model→all POIs
- New caption: m-solves vs 1-solve contrast; references Chs 5 and 6

### Caption updated to match new figure content

**Page count:** 154 (stable)
**Compile status:** 0 errors, 0 undefined references

## v1.8 — 2026-04-07  (Literature Review Pass 2 — 6 new references, 7 targeted edits)

### Ch8 — Purpose-driven framing added
- Extended opening paragraph with Razavi et al. (2021) framing:
  SA is defined by method rather than purpose; three goals
  (factor prioritization, fixing, mapping) call for different methods.

### Ch9 — Factor-fixing vs factor-prioritization distinction (§9.1)
- Added explicit three-goal taxonomy (Saltelli et al. 2000) to chapter opening.

### Ch9 — Jansen estimator endorsed with citation (§Computing Sobol Indices)
- Added Puy et al. (2022) finding: Jansen outperforms Saltelli (2002)
  formula across comprehensive benchmarking; Jansen is the safer default.

### Ch9 — eFAST footnote added (§Convergence)
- Footnote explaining eFAST as alternative path to total-order indices
  (Saltelli, Tarantola & Chan 1999); notes SALib implementation.

### Ch9 — Shapley effects paragraph added (§Correlated POIs)
- Explained Shapley value axioms, formula, and bracketing property S_j ≤ φ_j ≤ S_{T_j}.
  Cites Owen (2014). Notes SALib and R sensitivity package.

### Ch9 — New §"Beyond Variance: Moment-Independent Sensitivity" added
- Full treatment of Borgonovo δ-index: motivation (skewed epidemic distributions),
  definition with equation, when it disagrees with Sobol indices,
  validity under correlated inputs, computational cost and software.
  Cites Borgonovo (2007) and Lu & Borgonovo (2023).

### Ch9 — SALib software pointer added (§Bridge to Semester 2)
- Directed Python users to SALib (Herman & Usher 2017) and R sensitivity package.

### Bibliography — 6 new entries added
  borgonovo2007new, puy2022comprehensive, owen2014sobol,
  saltelli1999effast, saltelli2000ingredient, herman2017salib

**Page count:** 154 → 156
**Compile status:** 0 errors, 0 undefined references

## v1.9 — 2026-04-07  (Session A: GSR review + gap closures)

### GSR fixes on literature review additions
- Shapley bracketing: clarified as normalized Shapley effect Φ_j = φ_j/Var(Y);
  inequality now reads S_j ≤ Φ_j ≤ S_{T_j} (Owen 2014, eq. 2)
- Factor taxonomy citation updated from saltelli2000ingredient to
  saltelli2004sensitivity + saltelli2008global (the papers that formally
  name the three-goal taxonomy)

### Ch9 new §"Time-Varying Sensitivity" added (§9.1 subsection)
- Explains that S_{p_i}^{q_j}(t) varies over epidemic trajectory
- β dominates early; γ dominates near peak; both matter for final size
- Cost: N(m+2)×T evaluations (same sampling matrix reused)
- Cites Wu et al. (2013) for epidemic application

### Ch6 new subsection "Beyond ODEs: Pointer to the Wider Adjoint Universe"
- PDE adjoints, data assimilation (4D-Var), optimal control
- Connects ODE adjoint in Ch6 to Cacuci (1981) and Giles & Pierce (2000)
- Both references already in bibliography

### Ch9 §PRCC: Non-monotonicity limitation sharpened
- Added concrete SIR example: R_0 = kβ/γ is monotone, which is WHY PRCC works
- Added threshold/bifurcation counter-example where PRCC underestimates
- Cites saltelli1999effast

**Page count:** 156 (stable)
**Compile status:** 0 errors, 0 undefined references

## v1.10 — 2026-04-07  (Sessions B–D: MACR fixes + submission preparation)

### Session B — MACR corrections
- Time-varying SA cost corrected: N(m+2) ODE runs (not N(m+2)×T);
  each run produces full trajectory, Jansen estimator applied per time step
- δ-index description clarified: integral is twice the TV distance;
  factor ½ outside the expectation normalizes δ_i to [0,1]

### Session C — Submission preparation
- Copyright/colophon: removed remaining "Part 1 of two-semester sequence" text
- AMS subject classifications added to front matter (65-01, 34A55, 62-07, 92D30, 49K15, 65C05)
- Keywords added to front matter
- Submission documents created: SIAM_Submission_Checklist.md, CoverLetter_draft.md, Prospectus_outline.md

### Session D — Final compile and packaging
- 5-pass compile (pdflatex × 3 + bibtex + makeindex)
- PDF SHA-256: 6d33732b9acf9b37...
- Page count: 156 → 158 (AMS/keywords page)
- Compile status: 0 errors, 0 undefined references
- Submission package assembled

## v1.11 — 2026-04-07  (Dimensionlessness + graduate pointers)

### Ch2: Dimensionlessness warning added (after Unifying Idea 1)
- New paragraph: "Why normalization is not optional"
- Pound-and-inches analogy: comparing raw derivatives across parameters
  is incommensurable; normalized SIs are unit-free and fair
- Explains why tornado plot sorts by |SI| not |∂q/∂p|
- Index entry: sensitivity index!dimensionlessness

### Ch9 §9.1: Dimensionlessness reminder for sigma-normalized index
- One paragraph after the S_i^σ formula
- Explains that σ_i/σ_Y cancels units; result is a pure number
- Cross-references the Ch2 tornado plot explanation

### Ch9 §9.8 (Borgonovo): Graduate pointer added
- One sentence citing Borgonovo (2017) book for full mathematical treatment
- New BibTeX entry: borgonovo2017sensitivity

### Ch6 PDE adjoint subsection: Cacuci book pointer added
- One sentence citing Cacuci (2003) Volume I for graduate-level
  development of adjoint for general nonlinear functional equations
- New BibTeX entry: cacuci2003volume1

**Bibliography:** 55 entries (was 53)
**Page count:** 158 (stable)
**Compile status:** 0 errors, 0 undefined references
