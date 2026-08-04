# TargetAce: UI/UX Design System & Style Guide

---

## 🎨 1. Dark Obsidian Design System Overview

TargetAce's interface is built upon a cohesive **Dark Obsidian** visual theme. The aesthetic emphasizes high-contrast surfaces, sleek neon accents, clean typography hierarchy, and dynamic tactile micro-animations.

---

## 🖌️ 2. Color Palette Tokens (`AppColors`)

All color definitions are centralized in `lib/core/config/colors.dart`. Ad-hoc hex colors in UI widgets are strictly forbidden.

| Token Name | Hex Code | Purpose & Application |
| :--- | :--- | :--- |
| `AppColors.background` | `#0B0F19` | Primary scaffold & page background |
| `AppColors.card` | `#1E293B` | Container surface, elevated cards, dialog tiles |
| `AppColors.primary` | `#3B82F6` | Core brand color, primary buttons, active tabs |
| `AppColors.primaryDark` | `#1E40AF` | Hover/press state, secondary button fills |
| `AppColors.primaryLight` | `#60A5FA` | Subtitles, interactive text links, highlight icons |
| `AppColors.accent` | `#F59E0B` | Badges, streak icons, 3rd place podium highlights |
| `AppColors.textPrimary` | `#F8FAFC` | Main headings, primary body text (High contrast) |
| `AppColors.textSecondary` | `#94A3B8` | Subtitles, inactive labels, placeholders |
| `AppColors.textLight` | `#CBD5E1` | Dialog descriptions, helper hints |
| `AppColors.error` | `#EF4444` | Errors, disqualified status, negative marking |
| `AppColors.labelGreen` | `#22C55E` | Correct answers, active subscription badges, 1st place podium |
| `AppColors.divider` | `#334155` | Card dividers, subtle line separators |
| `AppColors.border` | `#475569` | Form input borders, active container outlines |
| `AppColors.white` | `#FFFFFF` | Pure white text on high-contrast surfaces |
| `AppColors.black` | `#000000` | Backdrop shadow overlays (with alpha) |

---

## 🔤 3. Typography System (`AppFonts`)

Typography is managed exclusively by `lib/core/config/typography.dart`.

### Strict Rule: No Direct GoogleFonts Instantiations
To maintain uniform rendering across devices and prevent visual regressions, **direct usage of `GoogleFonts.poppins()` or `GoogleFonts.hindSiliguri()` in page/widget code is forbidden**.

```dart
// ❌ WRONG - Direct GoogleFonts instantiation
Text(
  'Dashboard Summary',
  style: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  ),
);

// ✅ CORRECT - Mandatory AppFonts usage
Text(
  'Dashboard Summary',
  style: AppFonts.heading(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  ),
);
```

### Typography Methods & Fallback Hierarchy

1. **`AppFonts.heading(...)`**:
   - Used for page headers, section titles, card titles, and modal headers.
   - Primary Font: **Poppins** (with fallback to system sans-serif).
2. **`AppFonts.body(...)`**:
   - Used for body text, subtitles, form fields, button text, and list items.
   - Primary Font: **Poppins** / **Hind Siliguri** (for Bengali text rendering).

---

## 📱 4. Layout & Spacing Standards

- **Page Padding**: Standard screen edges use `EdgeInsets.all(16)` or `EdgeInsets.symmetric(horizontal: 16, vertical: 20)`.
- **Card Radius**: All cards, containers, and dialogs use a uniform `BorderRadius.circular(16)` or `12`.
- **Button Radius**: Interactive action buttons use `BorderRadius.circular(12)` or pill-shaped `32`.
- **Dividers**: Card list items use `CustomDivider.dotted()` or `CustomDivider(height: 1)` with `AppColors.divider`.

---

## ✨ 5. Motion & Micro-Animations

- **Tactile Touch Feedback**: Wrap interactive buttons with `SpringButton` to deliver a smooth scale-down effect (downscale to `0.96` on touch).
- **Loading State Wave**: Asynchronous text updates use `FadeWaveAnimation` to give a subtle pulse animation while data syncs in the background.
