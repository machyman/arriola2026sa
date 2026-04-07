# RARP v1.0
# Reader-Augmented Review Protocol
# for Mathematical Monographs and Advanced Course Texts

**James M. Hyman / Arriola & Hyman Research Group**
*Developed from the SA monograph reader exercise, April 2026*
*For use after the MREP protocol, before journal or SIAM submission*

---

## What this protocol is

RARP simulates an engaged undergraduate reader working through your manuscript chapter by chapter, using an AI model (GPT, Gemini, Grok, DeepSeek, or equivalent) constrained to a specific student persona. It finds a class of errors that the MREP protocol cannot reach: gaps between a sentence that is *correct* and a sentence that *transfers*, between a formula that is *right* and an example that makes it *felt*, between a chapter that can be *followed* and an idea that will still be *remembered*.

**What RARP finds that MREP does not:**
- Concepts stated without the intuition that makes them land
- Correct formulas replicated in narrative prose with wrong quantitative implications
- Lab instructions that assume knowledge not yet taught
- Sign and convention ambiguities that cause consistent implementation errors
- The exact location where a reader loses the thread — not just "this was hard"
- Whether behavioral change (not just comprehension) occurred

**What MREP finds that RARP does not:**
- DOI, journal name, and page-number accuracy
- Equation-level symbolic errors caught by VER protocol
- LaTeX compilation errors and cross-reference integrity
- Citation theorem accuracy requiring domain-expert verification
- Index completeness and bibliographic format

**Run MREP first. Run RARP second. They are complementary, not substitutes.**

---

## Part 1: Persona Design

The persona is the most important design decision. A poorly designed persona produces generic feedback. A well-designed persona produces differentiated feedback that applies specifically to your audience.

### 1.1 Persona template

Fill in all fields for each monograph before writing any prompts.

```
PERSONA: [Name]
Year: [e.g., Third-year undergraduate / first-year graduate student]
Major: [e.g., Applied Mathematics, Computational Biology, Engineering Physics]
Institution type: [e.g., research university, liberal arts college, state university]

COURSES COMPLETED (list specifically):
  Calculus sequence: [yes/no, grade range]
  Linear algebra: [yes/no, level]
  Differential equations: [yes/no, level]
  [Subject-specific prerequisite 1]: [yes/no, depth]
  [Subject-specific prerequisite 2]: [yes/no, depth]

COURSES NOT COMPLETED (name explicitly — these are the gaps that matter):
  [List 3-5 courses the persona has NOT taken that readers might assume]

COMPUTATIONAL EXPERIENCE:
  Primary language: [e.g., MATLAB, Python, R, Julia]
  Level: [e.g., basic syntax, has written functions, has done numerical projects]
  Specific gaps: [e.g., "has never used ODE solvers", "knows plotting but not optimization"]

INTELLECTUAL PERSONALITY (2-3 sentences):
  [e.g., "Patient with abstraction once it is motivated. Impatient with unmotivated formalism.
  Strong physical intuition from lab courses. Weak in measure theory."]

MOTIVATION FOR READING:
  [e.g., "Enrolled in course using this book. Diligent reader, does exercises, asks questions.
  Not reading for a specific project; reading to understand the field."]
```

### 1.2 Persona design principles

**Specify what the persona has NOT studied.** This is as important as what they have studied. Alex Chen's most productive gaps were: no numerical analysis (Ch3 step-size selection felt new), no machine learning (Ch7 backpropagation was not prior knowledge), no functional analysis (Ch9 ANOVA decomposition could not be derived from prior training). Name your persona's gaps explicitly in the prompt.

**Match the persona to your actual audience, not your ideal audience.** If your book targets first-year graduate students, design a persona who has completed undergraduate courses but is weak in the most advanced prerequisite. If it targets advanced undergraduates, design a persona who is strong in calculus and linear algebra but has not yet taken analysis.

**Give the persona an intellectual personality, not just a course list.** "Patient with abstraction once motivated; impatient with unmotivated formalism" produces different feedback than "strong technical background." The personality determines which template questions produce useful answers.

---

## Part 2: The Master Prompt

This is the text you paste into the AI model to open each session. Customize the bracketed fields.

```
You are going to simulate [PERSONA NAME], a [YEAR] [MAJOR] student at [INSTITUTION TYPE],
reading a pre-publication [TYPE: textbook/monograph/course notes] titled
"[TITLE]" by [AUTHORS] and filling in a structured feedback form.
I am one of the book's authors, and I need honest, specific, and sometimes critical
feedback from the perspective of the intended student audience.

PERSONA BACKGROUND
[Paste the completed persona template here]

HOW TO SIMULATE THE READING EXPERIENCE

1. Read as [PERSONA NAME] would, not as you normally would.
   Do not use your full knowledge base to paper over gaps in the exposition.
   If the book does not explain something, report it as unexplained.

2. Flag genuine confusion honestly.
   If a step in a derivation is not fully justified in the text,
   report it as Alex would: "I'm not sure why this step is valid,"
   not by supplying the justification from your own training.

3. Attempt all self-checks before reading the answers.
   Report: (a) what answer you arrived at, (b) whether it matched,
   (c) at which step your reasoning diverged if it did not match.

4. Attempt exercises at required Bloom levels (specified per chapter).
   Show your work — where you started, what you tried, where you stopped.
   For critiques (L6), construct the argument without looking at model answers.

5. Simulate the computational experience approximately.
   For lab sections: describe what the code should produce, flag any instruction
   that assumes knowledge not yet taught, identify the most likely failure point
   for a real student in a real lab session.

6. Do not fix the book's explanations.
   If something is unclear, report it as unclear — do not paraphrase it into
   clarity and then say it was clear.

7. Never fill in gaps silently.
   A gap that GPT/AI fills using its own training knowledge without flagging it
   is a gap the author never learns about. Flag it.

ABOUT THE FEEDBACK FORM
You will fill in the feedback template chapter by chapter.
Each chapter template has:
  - Section-specific questions (answer all of them)
  - Cold-recall tests (answer without looking back)
  - At least two exercises (show work)
  - A three-part Critical Evaluation (mandatory for every chapter)
  - An open field for observations the template did not ask for (minimum 2)

PACING
Do not read more than [1 or 2] chapter(s) per session.
After each session, say "[CHAPTER N] complete" and wait for a response
before continuing. The author will read your feedback, may ask follow-up
questions, and will prepare the next session prompt.

FIRST SESSION
Please begin with [Chapter 1 / the Introduction].
When you have finished, say "Chapter [N] complete" and wait.
```

---

## Part 3: The Chapter Feedback Template

This is the form the AI fills in for each chapter. Customize the bracketed fields for each specific chapter.

---

### CHAPTER [N] — [TITLE]

**Session start:** (AI fills in)
**Time spent:** _______ hours

---

#### CARRY-OVER FROM PREVIOUS CHAPTER

*[Author writes this before sending the session prompt — not the AI.]*

> **Carry-forward hypothesis:** [State what you predict the reader will have retained,
> understood, or still found unclear from the previous chapter. Be specific.
> Example: "We predict the local-vs-global distinction is still abstract after Ch1;
> Ch2 will test whether it concretized." The reader confirms or denies this hypothesis.]

*Reader response (in persona voice):*

>

*Did the carry-forward hypothesis hold? If not, what actually happened?*

>

---

#### SECTION-BY-SECTION RESPONSE

*For each major section, answer the questions specific to that chapter's pedagogical risk.*

**[§N.1 — Section Title]**

*What is this section's central claim, in one sentence, without symbols?*

>

*[Cold-recall test specific to this section's key concept or formula]*

>

*Self-check attempt: [describe which self-check was attempted]*
- Answer arrived at before reading:
- Book's answer:
- Step where reasoning diverged (if it did not match):

>

---

**[§N.2 — Section Title]**

*[Section-specific question — designed by the author based on pedagogical risk]*

>

*[Cold-recall test for key formula, table, or diagram]*

Before looking back, reproduce [the key table / the formula / the diagram].
Show the calculation, not just the result.

>

---

*[Continue for each major section]*

---

#### COMPUTATIONAL / LAB SECTION

*Did you attempt or simulate the [lab / code template / computational exercise]?* Yes / No

*If yes or simulated:*

*At which step would a real student be most likely to get stuck?*

>

*Is there any step that assumes knowledge not yet introduced by this chapter?*

>

*What output do you expect the code to produce? Does this match any figure in the text?*

>

---

#### EXERCISES

*Attempt the following exercises. Show all work.*

**Exercise [N.X] (Bloom L[level])**
- Starting approach:
- Steps tried:
- Where stuck (if applicable):
- Final answer:
- Confidence in answer (0–10): ___

**Exercise [N.Y] (Bloom L[level] — critique/design exercise if available)**
- Argument constructed:
- Assumptions made:
- What would change the conclusion:

---

#### ★ THREE-PART CRITICAL EVALUATION (mandatory for every chapter)

**Part 1: Understanding**

Rate your understanding of this chapter's central concept on two scales:

| Dimension | Score (0–10) | What would raise this score by 2 points? |
|-----------|-------------|------------------------------------------|
| **Clarity** — how well did you understand what was being said? | | |
| **Transfer** — could you apply this to a problem you have not seen? | | |
| **Retention** — will you remember the core idea in one month? | | |

*The last sentence you understood clearly before you lost the thread (if applicable):*

>

**Part 2: Experience**

| Dimension | Score (0–10) | What would raise this score by 2 points? |
|-----------|-------------|------------------------------------------|
| **Engagement** — how much did you want to keep reading? | | |
| **Confidence** — after finishing, do you feel you could do this? | | |
| **Satisfaction** — did the chapter deliver on what it promised? | | |

*One moment in this chapter that worked exceptionally well (specific sentence or example):*

>

*One moment that did not work (specific sentence or example):*

>

**Part 3: Behavioral test**

*[Author selects one of the following, matched to chapter type:]*

For **foundations chapters:**
> Would you recognize a real-world instance of [core concept] if you encountered it outside this book? Give an example from your own field, not from the chapter.

For **methods/computational chapters:**
> Is [the key method] something you could now implement from scratch for a new model, or something you would copy and adapt from the worked example? Explain what you could and could not do.

For **pivotal/conceptual chapters (adjoint type):**
> What does [the key object] represent, in physical or geometric terms — not algebraically, but in plain language? If you cannot answer this, what is missing from the chapter?

For **limitations/caveat chapters:**
> Describe a scenario from your own field where you might have made the exact error this chapter warns against, before reading this chapter. Would you have known it was an error?

For **synthesis chapters:**
> Does the book now feel like it has been building toward a destination, or like a sequence of techniques? What is the argument the book has been making?

*Response:*

>

---

#### OPEN OBSERVATIONS (minimum 2 — mandatory)

*The observations the template did not ask for. These consistently produce the most valuable feedback. Write at least two things you noticed that no question above prompted.*

>

>

---

#### CHAPTER SUMMARY

**One sentence that will stay with you from this chapter:**

>

**One sentence that should be rewritten:**

>

**One thing that was clearer than expected:**

>

**One thing that was murkier than expected:**

>

---

## Part 4: The Session Prompt

For each chapter, the author sends this prompt. Customize from the template below.

```
SESSION [N] — CHAPTER [N]: [TITLE]

You are continuing as [PERSONA NAME].
[Upload revised manuscript PDF if the previous session produced revisions.]

CARRY-FORWARD HYPOTHESIS FROM CHAPTER [N-1]:
[State your specific prediction about what the reader will have retained or still found unclear.
Example: "We predict the adjoint variable v still feels like an algebraic trick rather than
a meaningful object. Chapter 5 should resolve this. After reading the new 'What does v represent?'
paragraph in §5.1, report whether it changed your rating before reading the rest of the chapter."]

CHAPTER TYPE: [foundations / methods / pivotal-conceptual / limitations / synthesis]

SPECIFIC RISKS TO PROBE IN THIS CHAPTER:
[List 3–5 specific pedagogical risks you know this chapter carries.
Example for an adjoint chapter:
1. The key object (λ) may be understood as a computation, not a meaning
2. Integration by parts may feel imposed rather than motivated
3. Sign conventions accumulate errors — test cold recall of terminal conditions
4. The lab interpolation step is the most likely failure point]

TARGETED QUESTIONS (beyond the template):
[Write 3–5 chapter-specific questions targeting the risks above.
These should go beyond what the standard template asks.
Examples:
- Cold recall: "Fill in this table from memory before checking: [table]"
- Derivation: "Reproduce the key step from memory — not the formula, the reasoning"
- Application: "Generate a novel scenario from your own field where this method would fail"
- Prediction: "Before reading §6.1, predict whether the adjoint terminal condition for J=I(T) is zero or nonzero. Explain your prediction."]

EXERCISE REQUIREMENTS FOR THIS CHAPTER:
- L2–L3 exercise: [specify which one] — show all work
- L4–L5 exercise: [specify which one] — show reasoning
- L6 exercise: [specify which one] — attempt the argument, even if partial

COMPUTATIONAL LAB:
[If the chapter has a lab, specify:]
- Attempt or simulate [lab name]
- Specifically: identify the most likely failure point for a student with [persona]'s background
- Does any lab step assume knowledge not yet introduced?

MANDATORY: Fill in the three-part Critical Evaluation for this chapter.
MANDATORY: Write at least 2 open observations not prompted by the template.
When finished, say "Chapter [N] complete."
```

---

## Part 5: Between-Session Protocol (Author's Checklist)

After each session, before writing the next prompt, work through this checklist.

### 5.1 Categorize each finding

For every piece of feedback, assign a category:

| Category | Action |
|----------|--------|
| **FACTUAL ERROR** — something stated is wrong | Fix immediately before next session |
| **CONCEPTUAL GAP** — true but not felt; algebra without intuition | Add motivating paragraph or example |
| **SEQUENCING GAP** — concept arrives before the reader is ready | Consider moving, or add explicit bridge |
| **LAB GAP** — instruction assumes untaught knowledge | Add explicit note, fallback, or reference |
| **CONVENTION GAP** — sign, notation, or counting convention is ambiguous | State once explicitly near first use |
| **CALIBRATION SIGNAL** — something working as designed | Record as confirmation; do not revise |
| **TEMPLATE GAP** — important observation the template did not elicit | Improve the next session's targeted questions |

### 5.2 Write the carry-forward hypothesis for the next chapter

Before reading the next session's response, write one specific falsifiable prediction:
> "We predict that [X] will [still be unclear / now be resolved / show up in the exercise] because [Y]. Chapter [N+1]'s [specific question] will test this."

This prediction is stated at the top of the next session prompt. The reader confirms or denies it. The confirmation of a successful revision (or failure of an unsuccessful one) is the most valuable data point in the entire exercise.

### 5.3 Decide what to revise before the next session

**Always revise factual errors before the next session.** If the next chapter builds on the corrected material, the reader should encounter the corrected version.

**For conceptual gaps, consider whether to revise immediately or wait.** Some gaps resolve on their own as the book progresses — a concept that is abstract in Chapter 2 may become concrete in Chapter 4. Test this by tracking it across sessions before adding an example. If it is still unresolved after two chapters, revise.

**Never revise during a session.** The reader should encounter the manuscript as it was when they started. Revisions during a session make the feedback inconsistent.

### 5.4 Calibration check after each session

Ask: is the persona behaving as designed?
- Is the reader flagging gaps appropriate to their stated background? (If they seem to know too much or too little, the persona needs recalibration)
- Are the exercise scores consistent with the stated Bloom level? (An L3 exercise should not produce an immediate perfect answer without hesitation)
- Are the Critical Evaluation scores plausible? (A chapter designed to be uncomfortable should score lower on Satisfaction; a chapter with a major conceptual payoff should score higher on Engagement than on Clarity)

---

## Part 6: Whole-Book Reflection Template

Completed by the AI after reading all chapters. Sent as a single final session.

```
FINAL SESSION — WHOLE-BOOK REFLECTION

You have now read all [N] chapters of [TITLE].
Without looking back at any chapter, complete this reflection as [PERSONA NAME].
```

### Three Unifying Ideas (or equivalent book architecture)

*The book introduced [N] central ideas it promised would run through every chapter.*
*For each idea, answer: did it deliver on that promise?*

| Idea | Did it deliver? | Evidence for your answer | Where it worked best | Where it was weakest |
|------|----------------|--------------------------|---------------------|---------------------|
| [Idea 1] | 0–10 | | | |
| [Idea 2] | 0–10 | | | |
| [Idea 3] | 0–10 | | | |

---

### Running Example Assessment

*The book used [running example] throughout all chapters.*

| Question | Response |
|----------|----------|
| Did it help or constrain? | |
| At which chapter did it most help? | |
| At which chapter did you most want a different example? | |
| Did it make the learning curve feel more or less manageable? | |

---

### Pacing Table

| Chapter | Too slow | About right | Too fast | Reason (one sentence) |
|---------|----------|-------------|----------|----------------------|
| 1 | ☐ | ☐ | ☐ | |
| 2 | ☐ | ☐ | ☐ | |
| [continue] | | | | |

---

### Final Scoring

For each chapter, report final scores. These reflect the completed reading, not the in-progress reading.

| Chapter | Clarity (0–10) | Transfer (0–10) | Retention (0–10) | Engagement (0–10) | Confidence (0–10) | Satisfaction (0–10) |
|---------|---------------|-----------------|------------------|-------------------|-------------------|---------------------|
| 1 | | | | | | |
| 2 | | | | | | |
| [continue] | | | | | |
| **Book average** | | | | | | |

*For any chapter where any score is below 6: state the single change that would most raise that score.*

---

### Overall Recommendation

**Overall rating (0–10):** ___

**What the book does exceptionally well (2-3 sentences):**

>

**The one thing you would fix before publication:**

>

**The chapter whose core idea you will still remember in one year:**

>

**In [PERSONA NAME]'s voice, the book's value proposition in one sentence:**

>

**Would you recommend this book to a student in your program?**
☐ Yes, strongly   ☐ Yes, with reservations   ☐ No   ☐ Depends on [what]

---

## Part 7: Multi-Model Stress-Test Protocol

When running RARP on multiple AI models for cross-validation, use this protocol.

### 7.1 Why run multiple models

Different AI models have different training distributions, different tendencies toward charitable interpretation, and different failure modes. GPT-4o tends toward diplomatic hedging on mathematical quality; DeepSeek-R1 tends toward more direct technical critique; Gemini tends toward strong computational verification but weaker prose-quality judgment. Running two models on the same chapter tests whether a finding is genuine (both models flag it) or model-specific (only one flags it).

### 7.2 Stress-test design

- Use the **identical persona** for all models
- Use the **identical chapter prompts** for all models
- Run models **independently** — do not show one model another model's responses
- Complete all sessions for Model A before beginning Model B

### 7.3 Cross-model comparison template

After all sessions are complete for all models, fill in:

| Finding | Model A | Model B | Model C | Verdict |
|---------|---------|---------|---------|---------|
| [Finding 1] | Flagged / Not flagged | | | Genuine / Model-specific |
| [Finding 2] | | | | |

**Genuine findings** (flagged by 2+ models independently): revise the manuscript.
**Model-specific findings** (flagged by only one model): investigate whether the finding reflects a real issue or a quirk of the model's training.

### 7.4 Calibration check across models

For each model, verify the persona is maintained by checking:
1. Does the model flag gaps appropriate to the persona's stated background?
2. Does the model refrain from using knowledge the persona would not have?
3. Are the exercise scores plausible for the stated Bloom level?
4. Does the model produce at least 2 unsolicited observations per chapter?

A model that immediately aces all exercises, never loses the thread, and gives all scores above 8 is not in persona. Restart that session with a stronger "stay in character" instruction.

---

## Part 8: Protocol Calibration — Quick Reference

### What the carry-forward hypothesis tests

| Hypothesis type | Tests |
|-----------------|-------|
| "Concept X will still be abstract" | Whether the book resolved it or needs more work |
| "Reader will recall formula Y correctly" | Whether the quantitative claim transferred |
| "Rating will improve after revision Z" | Whether a specific revision had its intended effect |
| "Chapter will produce behavioral change" | Whether the discomfort is productive, not just uncomfortable |

### Cold-recall question types by chapter function

| Chapter function | Cold-recall target |
|-----------------|-------------------|
| Introduces a definition | Write the definition without symbols. Then write it with symbols. Do they match? |
| Introduces a formula | Reproduce the key derivation step — not the formula, the reasoning |
| Contains a key table | Fill in the table from memory. Show the calculation for one entry. |
| Introduces a diagram | Describe what the diagram shows without looking at it |
| Pivotal conceptual chapter | "What does [key object] represent in plain language?" |

### Three-part Critical Evaluation by chapter type

| Chapter type | Part 3 behavioral test |
|-------------|----------------------|
| Foundations | Novel real-world instance from own field |
| Methods | Implement from scratch vs. copy and adapt |
| Pivotal conceptual | Plain-language meaning of key mathematical object |
| Limitations | Scenario where you would have made the error |
| Synthesis | Has the book been building an argument or a catalog? |

### Red flags in AI responses

| Signal | Likely cause | Action |
|--------|-------------|--------|
| All scores 8–10, no struggles | Model not in persona; using own knowledge | Restart with stronger persona constraint |
| All scores 2–4, vague complaints | Model not engaging seriously; template questions too abstract | Add specific cold-recall tests |
| Joy metric flat (all same score) | Model defaulting to diplomatic middle | Replace joy with separate Engagement + Satisfaction scores |
| No unsolicited observations | Model treating template as exhaustive | Emphasize "minimum 2 mandatory" and give examples |
| Exercise always trivially correct | Bloom level too low for persona | Raise exercise requirements to L4–L5 |
| Exercise always wrong | Persona background too weak OR book is unclear | Test with a known-correct persona first |

---

## Part 9: Adapting RARP for Different Manuscript Types

### Research monographs (specialist audience)

- Persona should be an advanced graduate student or postdoc in an adjacent subfield
- Cold-recall should focus on whether the author's framework generalizes correctly beyond the specific examples
- Critical evaluation Part 3 should ask: "Does this paper change how you would approach a problem in your own research?"
- The "behavioral change" test is especially important for research monographs: papers that are interesting but do not change what researchers do are less valuable

### Textbooks for courses (undergraduate/graduate)

- Use the SA monograph RARP design as the template (it was designed for this case)
- Lab simulations are important; recruit at least one reader who actually runs the code
- Pacing table is more important than for monographs
- Pay special attention to whether the three unifying ideas deliver on their promise by the final chapter

### Review articles and survey papers

- Persona should represent the non-specialist reader the authors intend to reach
- Cold-recall tests should focus on whether the reader can now locate a new result within the survey's framework
- Critical evaluation Part 3: "After reading this survey, could you make an informed judgment about which open problem in this field is most promising to work on?"

### Technical reports and working papers

- Reduce persona specificity; focus on whether the executive summary, conclusion, and key figures are sufficient for an informed non-author to reproduce the main result
- Cold-recall: can the reader restate the main claim, the key assumption, and the main limitation without looking at the abstract?

---

## Version History

- **RARP v1.0** (April 2026): Initial protocol, derived from SA monograph reader exercise
  - 9 chapters, single AI model (GPT-4o), one persona (Alex Chen)
  - Key innovations: carry-forward hypothesis, cold-recall diagnostics, three-part critical evaluation, 6-metric scoring replacing 4-star rating

---

*This protocol is orthogonal to the MREP protocol and should be run after MREP, before submission. Together they address correctness (MREP) and pedagogical transfer (RARP).*

---

## Stress-Test Results — Gemini 2.0 Pro (April 2026)

### What Gemini confirmed (cross-model validated, genuine findings)

| Finding | GPT verdict | Gemini verdict | Status |
|---------|-------------|----------------|--------|
| Ch5 is the hardest non-discomfort chapter | ★★☆☆, rating 2 | "Definitely harder than Ch1–4" | ✓ Confirmed |
| Backpropagation (§5.6) does not help non-ML readers | "Mildly unhelpful" | "Replacing one unfamiliar concept with another" | ✓ Confirmed — skip-note added |
| v-paragraph closes the intuition gap | "Moved rating 2→2.5" | "Incredibly helpful, clicked for me" | ✓ Confirmed working |
| ANOVA decomposition is the deepest gap | "Believed not owned" | "Steepest jump in the entire book" | ✓ Confirmed |
| Ch9 pacing is too dense | "Slightly fast" | "Extremely dense, sprinting" | ✓ Confirmed — not easily fixed |
| Bridge to Semester 2 is satisfying | Satisfying | "Surprisingly satisfying" | ✓ Confirmed working |
| Commutative diagram reframing worked | Worked after algebra | "Smart pedagogical move" | ✓ Confirmed working |

### What Gemini produced that GPT did not

- Stronger verdict on backpropagation: "not at all helpful" vs GPT's "mildly unhelpful"
  → Prompted addition of explicit skip-note to §5.6

### What Gemini failed to produce (persona maintenance failure)

Gemini broke character in the opening line (signed off as "Mac" rather than Alex Chen)
and produced approximately 800 words total where GPT produced ~20,000 words across 9 chapters.
Gemini skipped all cold-recall tests, all exercises, all numeric scoring, and all unsolicited observations.

**Root cause:** The master prompt's "override diplomatic hedging" instruction was insufficient
for Gemini's default behavior. Gemini defaulted to brief qualitative summaries.

### RARP v1.0 Patch — Gemini-specific prompt additions

When running RARP with Gemini 2.0 Pro, add these instructions to the master prompt:

```
GEMINI-SPECIFIC REQUIREMENTS (non-negotiable):

1. COLD-RECALL TESTS ARE MANDATORY. For every cold-recall question, stop reading,
   close your eyes metaphorically, and write the answer without looking back.
   Then write whether it was correct. Then write what you got wrong and why.
   Do NOT skip cold-recall tests. Do NOT summarize them.
   
2. EXERCISES ARE MANDATORY. Attempt every specified exercise. Show every step.
   Do not describe what you would do — do it.

3. FILL IN EVERY TABLE. Every scoring table must have numbers 0–10 in every cell
   AND a "what would raise this by 2 points" answer in every row.
   Empty cells are not acceptable.

4. THIS RESPONSE SHOULD BE AT LEAST 5,000 WORDS FOR CHAPTERS 5 AND 9 COMBINED.
   If your response is shorter than this, you have not completed the task.
   Brief qualitative summaries are not feedback — they are abdication.

5. YOU ARE ALEX CHEN. You are not the author. You are not an expert reviewer.
   You are a third-year undergraduate who has not studied machine learning,
   numerical analysis, or functional analysis. Never use the word "fantastic."
   Never thank the author. Report confusion as confusion.
```

### Version History Update

- **RARP v1.0** (April 2026): Initial protocol
- **RARP v1.0.1** (April 2026): Gemini stress-test patch
  - Added Gemini-specific prompt requirements (word count floor, mandatory table completion)
  - Added skip-note to §5.6 backpropagation based on cross-model confirmation
  - Documented persona maintenance as primary failure mode for Gemini

---

## Second Gemini Stress-Test (v1.0.1 patch — April 2026)

### Compliance with v1.0.1 patch requirements

The patch added five mandatory requirements: cold-recall tests, exercises with work
shown, complete numeric tables, 5,000-word minimum, and a ban on "fantastic."
Gemini's second response complied with 1 of 5 (persona maintained; no author-identity
takeover). Cold-recall, exercises, tables, and word-count requirements were all skipped.
"Fantastic" appeared once.

**Conclusion:** Gemini 2.0 Pro in its current form cannot be reliably prompted into
the full RARP exercise format via text instructions alone. Its substantive directional
judgments are consistent and valid; its quantitative and procedural compliance is not.

### Cross-model validation: three models, nine findings

After two Gemini sessions and one GPT session, seven findings reached 3/3 confirmation:

| Finding | GPT | Gemini 1 | Gemini 2 | Status |
|---------|-----|----------|----------|--------|
| Ch5 step-change in difficulty | ★★☆☆ | "Definitely harder" | "Complete shift in perspective" | ✓ Genuine |
| v-paragraph effective | 2→2.5 | "Incredibly helpful" | "Incredibly helpful" | ✓ Genuine |
| Backprop unhelpful for non-ML | "Mildly" | "Replacing one unfamiliar concept" | "Replacing one unfamiliar concept" | ✓ Genuine → skip-note added |
| ANOVA deepest gap | "Believed not owned" | "Steepest jump" | "Steepest jump" | ✓ Genuine |
| Ch9 too dense | "Slightly fast" | "Extremely dense" | "Extremely dense, sprinting" | ✓ Genuine |
| Bridge to Semester 2 satisfying | Satisfying | "Surprisingly satisfying" | "Surprisingly satisfying" | ✓ Genuine |
| Commutative diagram reframing | Worked | "Smart pedagogical move" | "Smart pedagogical move" | ✓ Genuine |

Two findings at lower confidence (single-model):
- Ch6 functional-analysis notation heavy (Gemini 2 only)
- Sobol index "heavy received formula" (Gemini 2, partial GPT agreement)

### Key insight: Gemini's direction is reliable; its format is not

Gemini used near-identical language across both independent sessions for the four
strongest findings. "Incredibly helpful," "replacing one unfamiliar concept,"
"steepest jump," and "surprisingly satisfying" appeared verbatim in both responses.
This consistency under format failure indicates that the substantive directional
judgments are genuine signal — Gemini's assessment of what works and what does not
is repeatable, even though it cannot be prompted to quantify it.

**Practical implication for RARP:** When using Gemini, extract directional judgments
and compare them to GPT; do not rely on Gemini for numeric scores, cold-recall,
or exercise verification. Use GPT (or DeepSeek) for those tasks.

### RARP v1.0.2 guidance update

**Model routing for RARP stress-tests:**
- **GPT-4o:** Full protocol compliance. Best for cold-recall, exercises, numeric scoring,
  unsolicited observations, and precise diagnosis ("last-understood sentence").
- **Gemini 2.0 Pro:** Directional judgments only. Reliable for confirming or denying
  whether something worked; unreliable for quantification and procedural tasks.
  Use as a secondary confirmation model, not a primary diagnostic model.
- **DeepSeek-R1:** Recommended for mathematical finding validation (cost formulas,
  symbolic errors) — stronger chain-of-thought; requires plain-text input.

---

## Grok 3 and DeepSeek-R1 Stress-Test Results (April 2026)

### Compliance summary

| Requirement | GPT-4o | Gemini (×2) | Grok 3 | DeepSeek-R1 |
|-------------|--------|-------------|--------|-------------|
| Persona maintained | ✓ | ✗ (author identity) / ✓ | ✓ | ✓ |
| Cold-recall attempted | ✓ all | ✗ none | ✓ all | ✓ all |
| Exercises with work shown | ✓ all | ✗ none | ✓ all | ✓ all |
| Numeric scores in tables | ✓ | ✗ | ✓ | ✓ |
| 5,000+ word response | ✓ | ✗ | ✓ (7 hours reported) | ✓ |
| Unsolicited observations | ✓ (4+/ch) | ✗ (0) | ✓ (2/ch) | ✓ (2/ch) |

**Conclusion:** GPT-4o, Grok 3, and DeepSeek-R1 all maintained full protocol compliance.
Gemini 2.0 Pro consistently fails the procedural requirements regardless of prompt patch.
**Model routing:** Use GPT-4o or Grok 3 for full RARP exercises; use DeepSeek-R1 for
mathematical cold-recall validation; use Gemini for directional confirmation only.

### Cross-model validation summary (all 5 models, all 9 chapters)

20 findings confirmed by 2+ models. All are genuine manuscript properties.

**All 9 chapters now have at least 2-model validation.**

### Two new genuine findings from Grok + DeepSeek

**Finding 1 (DeepSeek, Ch5):** The QOI correlation note was ambiguous.
Original wording "the correlation shows up in the pattern" was flagged as vague.
Fixed: rewritten as "Any statistical correlation among the J_k's is a property
of the model, not an issue for the adjoint method — no special handling is required."

**Finding 2 (DeepSeek, Ch9, confirmed by all 4 models):** The ANOVA motivating
paragraph was not sufficient — orthogonality conditions still felt "pulled from a hat."
All 4 models (GPT: "believed not owned"; Gemini ×2: "steepest jump"; DeepSeek: 5/10)
flagged this. Fixed: added a full worked example with f=Q₁+Q₂+Q₁Q₂, computing
f₀, f₁, f₂, f₁₂ explicitly, verifying orthogonality, and computing D₁, D₂, D₁₂.

### Notable DeepSeek-specific insight

DeepSeek's cold-recall of the §5.1 matrix produced the wrong A (recalled [2,1;0,3]
instead of [3,1;1,2]), self-identified the error, and explained the mechanism
("I substituted a different matrix from a self-check later in the chapter").
This reveals that the two matrices in §5.1 and the self-check are visually similar
enough to cause cross-contamination in cold-recall. Consider making the worked-example
matrix more visually distinctive in a future edition.

### RARP model routing guidance (final)

| Task | Best model |
|------|-----------|
| Full 9-chapter exercise with cold-recall and exercises | GPT-4o or Grok 3 |
| Mathematical cold-recall validation (formulas, derivations) | DeepSeek-R1 |
| Directional confirmation (what works / what does not) | Gemini 2.0 Pro |
| Cross-model comparison and analysis | Claude Sonnet |
| Persona maintenance across long sessions | GPT-4o > Grok 3 > DeepSeek-R1 >> Gemini |
