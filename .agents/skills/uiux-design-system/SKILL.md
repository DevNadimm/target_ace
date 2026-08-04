---
name: uiux-design-system
description: TargetAce UI/UX Design System & Style Guide. Use this skill when creating or modifying any Flutter page, widget, or component to ensure design consistency. Triggers on UI work, page creation, widget design, styling, layout, and component usage.
---

# TargetAce — UI/UX Design System & Style Guide

> **Version**: 1.0 · **Last Updated**: 21 July 2026
> **Role**: This document is the **single source of truth** for all UI/UX decisions across the TargetAce Flutter app. Every new page, widget, or component **must** follow these rules.

---

## 1. Brand Identity

| Attribute | Value |
| :--- | :--- |
| **App Name** | TargetAce |
| **Theme** | Premium Dark Mode (Obsidian + Logo Orange) |
| **Mood** | Luxurious, Focused, Competitive, Minimalistic, Eye-friendly |
| **Target Audience** | Bangladeshi students preparing for BCS, Admission, HSC |

---

## 2. Color Tokens

> All colors are defined in `lib/core/config/colors.dart`. **Never hardcode hex values**; always use `AppColors.*`.

### 2.1 Backgrounds & Surfaces

| Token | Hex | Usage |
| :--- | :--- | :--- |
| `background` | `#0C0C0D` | Scaffold, AppBar, BottomNav |
| `surface` | `#19191B` | Elevated surfaces |
| `card` | `#19191B` | Card backgrounds (same as surface) |
| `cardAlt` | `#141415` | Deep matte card alternative |

### 2.2 Primary (Logo Orange)

> **Design Principle**: Use the primary color *sparingly* as an accent to ensure an eye-friendly, premium experience (similar to how Facebook uses blue). Do not oversaturate the UI with orange.

| Token | Hex | Usage |
| :--- | :--- | :--- |
| `primary` | `#F97316` | CTA buttons, active states, badges, accents (use sparingly) |
| `primaryLight` | `#FDBA74` | Soft Orange Glow |
| `primaryLight2` | `#2A1B0D` | Soft dark transparent orange overlay |
| `primaryDark` | `#C2570F` | Deep Burnt Orange |
| `primary10` | `#1F150C` | 10% Opacity Orange |

### 2.3 Typography Colors

| Token | Hex | Usage |
| :--- | :--- | :--- |
| `textPrimary` | `#F5F5F5` | Headings, names, primary content |
| `textSecondary` | `#9A9A9C` | Subtitles, handles, secondary info |
| `textLight` | `#6B6B6D` | Muted hints, timestamps, placeholders |

### 2.4 Status Colors

| Token | Hex | Usage |
| :--- | :--- | :--- |
| `success` / `labelGreen` | `#059669` | Correct answers, positive trends, live status |
| `error` / `accent` | `#E11D48` | Wrong answers, destructive actions, live badges |
| `warning` / `accentYellow` | `#D97706` | Stars, streaks, rank highlights |
| `info` | `#3B82F6` | Informational notices |

### 2.5 Neutral Greys

| Token | Hex | Usage |
| :--- | :--- | :--- |
| `grey` | `#28282A` | Borders, dividers, muted pill backgrounds |
| `greyDark` | `#3E3E40` | Disabled button backgrounds |
| `divider` / `inputBorder` | `#28282A` | Line separators, form field borders |

---

## 3. Typography System

> All text styles are defined in `lib/core/config/typography.dart`. **Never use raw `TextStyle()`**; always use `AppFonts.heading()` or `AppFonts.body()`.

### 3.1 Font Families

| Role | Font | Method |
| :--- | :--- | :--- |
| **Headings** (serif, branding) | **Fraunces** | `AppFonts.heading(...)` |
| **Body/UI** (sans-serif, buttons, labels) | **Poppins** | `AppFonts.body(...)` |

### 3.2 Font Size Scale

| Category | Size | Weight | Font | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Page Title** | `20` | `Bold` | `heading` | AppBar title (only on tab pages) |
| **Section Header** | `16` | `Bold` | `body` | Section titles like "Recent Exam History" |
| **Card Title** | `14-18` | `Bold` | `heading` | Exam title, battle name inside cards |
| **Body Text** | `13-14` | `w500-w600` | `body` | Descriptions, countdown text |
| **Small Label** | `11-12` | `w600-Bold` | `body` | Badges, timestamps, handles, "See All" |
| **Micro Label** | `8.5-10` | `Bold` | `body` | "YOU" tag, badge text, letter-spaced labels |
| **Category Label** | `12` | `Bold` | `body` | "YOUR TARGET", "LIVE NOW" (with `letterSpacing: 1.0`) |

### 3.3 Typography Rules

```
✅ DO:
- Use AppFonts.heading() ONLY for page titles and big branding text
- Use AppFonts.body() for EVERYTHING else (buttons, labels, cards, lists)
- Use letterSpacing: 1.0 for uppercase category labels
- Use height: 1.4 for multi-line body text

❌ DON'T:
- Use GoogleFonts.poppins() or GoogleFonts.getFont() directly in page files
- Use raw TextStyle() anywhere
- Use AppFonts.heading() for section headers (it's for page-level titles only)
```

---

## 4. Spacing System

| Token | Value | Usage |
| :--- | :--- | :--- |
| **Page Padding** | `16px` horizontal | `EdgeInsets.symmetric(horizontal: 16)` |
| **Card Internal Padding** | `16px` all (via `CustomContainer`) or `20px` for hero cards |
| **Section Gap** | `24px` | Between major sections |
| **Card Gap** | `10-14px` margin bottom | Between stacked cards |
| **Inline Gap** | `6-12px` | Between icons and text, between badges |
| **Bottom Safety** | `32px` or `80px` (if above bottom nav) | Scroll padding at page bottom |

---

## 5. Core Components

### 5.1 `CustomContainer` — Standard Card

> Defined in `lib/core/components/custom_container.dart`

```dart
CustomContainer(
  padding: const EdgeInsets.all(16),  // Default
  child: ...,
)
```

| Property | Default Value |
| :--- | :--- |
| `color` | `AppColors.card` (#18181B) |
| `borderRadius` | `16px` |
| `border` | `1px AppColors.inputBorder` (#27272A) |
| `boxShadow` | Subtle `0.01 alpha` black, `blurRadius: 12` |

> Use `CustomContainer` for **all standard cards**. Only use raw `Container` with custom `BoxDecoration` for **hero/gradient cards**.

### 5.2 `CustomDivider` — Line Separator

```dart
const CustomDivider()        // Gradient solid line
CustomDivider.dotted()       // Dashed line
```

### 5.3 `SpringButton` — Primary CTA Button

```dart
SpringButton(
  backgroundColor: AppColors.primary,
  onPressed: canTap ? () => ... : null,  // null = disabled
  child: Center(child: Text(...)),
)
```

| Property | Default Value |
| :--- | :--- |
| `height` | `50px` |
| `borderRadius` | `12px` |
| `depth` | `4.0` (3D tactile effect) |

**Button States**:
- **Active**: `backgroundColor: AppColors.primary`, text `Colors.white`
- **Disabled**: `backgroundColor: AppColors.greyDark`, text `AppColors.textSecondary`, `onPressed: null`
- **Live/Success**: `backgroundColor: AppColors.labelGreen`
- **Submitted**: `backgroundColor: AppColors.grey.withValues(alpha: 0.2)`

### 5.4 `GradientBackground` — Page Background

**Every page body** must be wrapped in `GradientBackground(child: ...)`.

---

## 6. Layout Patterns

### 6.1 Page Structure (Tab Pages)

```
Scaffold
├── AppBar (transparent, elevation: 0)
│   └── title: AppFonts.heading(fontSize: 20, bold)
│   └── automaticallyImplyLeading: false
└── body: GradientBackground
    └── BlocBuilder
        └── RefreshIndicator
            └── SingleChildScrollView / CustomScrollView
```

### 6.2 Section Header Pattern

```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 4),
  child: Text(
    'Section Title',
    style: AppFonts.body(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
  ),
)
```

### 6.3 Category Label Pattern

```dart
Text(
  "YOUR TARGET",
  style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.0),
)
```

### 6.4 Badge / Pill Pattern

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.primary.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text('Label', style: AppFonts.body(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
)
```

### 6.5 Metric Badge Pattern

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.primary.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
  ),
  child: Row(children: [HugeIcon(...), SizedBox(width: 4), Text(...)]),
)
```

---

## 7. Hero Card Pattern

Hero cards use **raw Container** with custom gradient (NOT `CustomContainer`).

```dart
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.primaryDark.withValues(alpha: 0.8), AppColors.cardAlt],
      begin: Alignment.topLeft, end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 16, offset: Offset(0, 6))],
  ),
)
```

---

## 8. Icon System

| Library | Usage |
| :--- | :--- |
| **HugeIcons** | Primary icon set (strokeRounded variants) |
| **Material Icons** | Supplementary (check_circle, cancel, star, fiber_manual_record) |
| **Custom SVG** | Bottom nav icons only (via `Assets.*`) |

**Sizes**: Nav `24px`, Card inline `14-16px`, Empty state `64px`, Watermark `110px`

---

## 9. State Management Rules

| Pattern | Usage |
| :--- | :--- |
| **BLoC** | All data-fetching pages |
| **StatefulWidget** | Only for local UI state (timers, animations) |
| **ValueNotifier** | Ephemeral loading states |

> **Never use `setState` for data fetching.** Always use BLoC + Repository.

---

## 10. Duration Formatting

```dart
// Hours present:  "02 hrs 08 mins"
// Minutes only:   "08 mins 45 secs"
// Seconds only:   "45 secs"
// Zero:           "00 mins"
```

---

## 11. Consistency Checklist

Before submitting any new page or widget:

- [ ] Uses `GradientBackground` as body wrapper
- [ ] Uses `AppFonts.heading()` only for page-level titles
- [ ] Uses `AppFonts.body()` for all other text
- [ ] Uses `CustomContainer` for standard cards
- [ ] Uses `SpringButton` for primary CTAs
- [ ] Uses `CustomDivider` for separators
- [ ] Uses `AppColors.*` tokens (no hardcoded hex)
- [ ] Uses `HugeIcons.strokeRounded*` for icons
- [ ] Page horizontal padding is `16px`
- [ ] Section gaps are `24px`, card gaps `10-14px`
- [ ] No `setState` for data fetching — uses BLoC
- [ ] Tab pages have `automaticallyImplyLeading: false`
