# UJobs App - Core Directives

## 1. Session Startup Checklist
Before starting work in a new session, you MUST:
- **Caveman Mode:** Verify Caveman mode is ON.
- **Review Context:** Check CodeGraph, RTK, and `PROJECT_SUMMARY.md`.
- **Skills Check:** Look for "Skills" in `PROJECT_SUMMARY.md`. If missing, add the skills before starting work. If present, proceed.

## Coding Standards
- **Reusable Widgets & Utils:** Always analyze `lib/core/widgets/` and `lib/core/utils/` before writing UI. Dynamically optimize code by reusing existing custom widgets. **NEVER** duplicate logic. If a UI element (e.g., card, button, chip) is used in multiple places, extract it into a dedicated reusable widget in `lib/core/widgets/`.
- **Strict Multi-language (l10n):** NO STATIC TEXT in the UI. All app-generated text MUST be dynamic via localization (`context.l10n`). This applies to headings, hints, button labels, and inline spans. Add new strings to `app_en.arb` and `app_ar.arb` BEFORE using them.
- **API Data:** Text coming from API responses is exempt. Render API data directly without local translation.
- **Icons:** Always use `HugeIcons` (specifically `HugeIcons.strokeRounded*`). Do NOT use Flutter's default Material `Icons` class.