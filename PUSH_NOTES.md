# Push set — v1_17_25 artifacts, with versioned filenames

## Files

    paper/sensitivity_analysis_book_v1_17_25.pdf      200 pp
    solutions/solutions_manual_v1_17_25.pdf            95 pp
    docs/solutions_manual_v1_17_25.pdf                 95 pp   (byte-identical twin)
    CITATION.cff                                       version -> v1_17_25

## YOU MUST DELETE TWO FILES AFTER PUSHING

GitHub uploads do not delete. After this push the old unversioned copies remain:

    paper/sensitivity_analysis_book.pdf        <- DELETE, stale (pre-SA38 content)
    solutions/solutions_manual.pdf             <- DELETE, stale (prints 5674.54)
    docs/solutions_manual.pdf                  <- DELETE, stale

Leaving them is worse than not renaming at all: a reviewer opening the unversioned file gets the
old Chapter 6 values while the notebooks now produce the corrected ones.

## The version is also inside the documents now

A filename does not survive downloading, renaming or printing. Both volumes now carry the version

  - on the title page, and
  - in a running footer on **every page**

driven by a single `\bookversion` macro in the shared `notation_macros.tex`. A colleague writing
"p. 47, second paragraph" is now unambiguous without reference to the filename.

## Noted, not changed

The solutions manual's title page reads `\date{April 2026}` while the book uses `\today`.
