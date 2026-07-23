# Companion materials — *Foundations of Sensitivity Analysis*

Companion code for ***Foundations of Sensitivity Analysis: From Local Sensitivity to Global
Uncertainty*** by Leon M. Arriola and James M. Hyman. Submitted to the SIAM *Computational Science and
Engineering* series.

---

## What is here now

**Nine Python notebooks**, one per chapter, that reproduce the worked examples and figures in the
text. Each runs end to end in Google Colab with no local installation and no data files — click a
badge to open one directly, no download and no account setup required.

| Chapter | Notebook | Run it |
|---|---|---|
| 1 — Why sensitivity analysis | `python/ch01_intro.ipynb` | [![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/machyman/arriola2026sa/blob/main/python/ch01_intro.ipynb) |
| 2 — Local sensitivity indices | `python/ch02_local_sa.ipynb` | [![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/machyman/arriola2026sa/blob/main/python/ch02_local_sa.ipynb) |
| 3 — Computing derivatives | `python/ch03_computing.ipynb` | [![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/machyman/arriola2026sa/blob/main/python/ch03_computing.ipynb) |
| 4 — Forward sensitivity equations | `python/ch04_analytic_forward_sensitivity_analysis.ipynb` | [![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/machyman/arriola2026sa/blob/main/python/ch04_analytic_forward_sensitivity_analysis.ipynb) |
| 5 — The adjoint in linear algebra | `python/ch05_the_adjoint_in_linear_algebra.ipynb` | [![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/machyman/arriola2026sa/blob/main/python/ch05_the_adjoint_in_linear_algebra.ipynb) |
| 6 — The adjoint for dynamical systems | `python/ch06_adjoint_odes.ipynb` | [![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/machyman/arriola2026sa/blob/main/python/ch06_adjoint_odes.ipynb) |
| 7 — Automatic differentiation | `python/ch07_adjoint_practice.ipynb` | [![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/machyman/arriola2026sa/blob/main/python/ch07_adjoint_practice.ipynb) |
| 8 — When sensitivity analysis misleads | `python/ch08_caveat_emptor.ipynb` | [![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/machyman/arriola2026sa/blob/main/python/ch08_caveat_emptor.ipynb) |
| 9 — Global sensitivity analysis | `python/ch09_global_sa.ipynb` | [![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/machyman/arriola2026sa/blob/main/python/ch09_global_sa.ipynb) |

## What is coming

The complete **MATLAB reference library** — production-quality functions, automated test suites,
and usage examples — will be released with the published book, alongside Python and R ports. Each
function in that library corresponds directly to a concept or algorithm in the text.

Until then, the pseudocode in the book describes every algorithm independently of language, and
these notebooks provide a working reference implementation in Python.

---

## Running the notebooks

Click any **Open in Colab** badge above. Nothing is installed locally and no account setup is
needed beyond a Google login.

Cells are meant to be executed **in order**. Several notebooks build state across cells — for
example, `ch06_adjoint_odes.ipynb` computes the forward solve, the backward adjoint solve, and
the sensitivity integrals in successive cells, and the later verification and figure cells depend
on those results.

Dependencies are limited to `numpy`, `scipy`, and `matplotlib`, all preinstalled in Colab.
`ch09_global_sa.ipynb` additionally uses `SALib`, which the notebook installs on first run.

## Verification

Each notebook ends with an assertion-based verification suite rather than printed output alone.
The suites check structural identities that must hold independently of solver tolerances — for
instance, in `ch06`, that the normalized indices for the contact rate `c` and the transmission
probability `β` are equal, since the two enter the model only through the product `cβ`.

If a notebook runs to completion without an `AssertionError`, its numerical claims agree with the
book.

## Reproducing the Chapter 6 sensitivity table

`ch06_adjoint_odes.ipynb` defines `run_sir_adjoint(p)`, which returns the raw derivatives
`dJ/dp_j` and the normalized sensitivity indices for the burden functional `J = ∫₀⁹⁰ I dt`. This
is the function cited in the solutions manual for Exercise 6.3:

```python
r = run_sir_adjoint(sir_nominal())
# J = 5674.5356
#      c:  raw dJ/dp =    +845.5035    SI = +0.744998
#   beta:  raw dJ/dp =  +70458.6272    SI = +0.744998
#  tau_R:  raw dJ/dp =   +1320.9593    SI = +1.629510
#  tau_m:  raw dJ/dp =      +0.0000    SI = +0.000000
```

Two structural checks hold: `dJ/dβ ÷ dJ/dc = c/β = 83.333` exactly, and `S_c = S_β` to six
significant figures.

---

## Citation

```bibtex
@book{arriola2026foundations,
  author    = {Arriola, Leon M. and Hyman, James M.},
  title     = {Foundations of Sensitivity Analysis: From Local Sensitivity
               to Global Uncertainty},
  publisher = {Society for Industrial and Applied Mathematics},
  series    = {Computational Science and Engineering},
  note      = {Manuscript under review; details subject to change},
  year      = {2026}
}
```

## License

Code in this repository is released under the MIT License. The text of the book is published by
SIAM and is not covered by that license.

---

*Leon Arriola died before this book was finished. The work is his as much as anyone's.*
