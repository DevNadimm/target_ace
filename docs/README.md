# TargetAce Documentation Hub & Central Sitemap

Welcome to the comprehensive documentation hub for **TargetAce**, a real-time competitive examination and practice platform built with Flutter and Supabase.

---

## 📚 Central Documentation Sitemap

| Document | Title & Focus | Key Technical Topics Covered |
| :--- | :--- | :--- |
| **[project.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/project.md)** | **Project Vision & PRD** | Executive summary, user personas (Rahat, Sadia), problem statement, solution modules, 3-phase roadmap, success KPIs. |
| **[features.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/features.md)** | **Features & Specifications** | Live Battle Engine state machine (Waiting, Active, Analyzing, Scoreboard), Anti-cheat telemetry, Practice Hub, bKash/Nagad local paywall, pre-filled WhatsApp support links. |
| **[engineering.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/engineering.md)** | **Engineering Architecture** | Clean Architecture (Domain, Data, Presentation), complete codebase directory sitemap, `GetIt` ServiceLocator container (`service_locator.dart`), coding standards. |
| **[ui_ux.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/ui_ux.md)** | **UI/UX Design System** | Dark Obsidian color palette (`AppColors`), mandatory `AppFonts` typography system, layout & spacing rules, `SpringButton` touch physics, micro-animations. |
| **[backend.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/backend.md)** | **Backend & Supabase Database** | ER diagram, table schemas (`profiles`, `exams`, `questions`, `exam_submissions`, `leaderboards`), `submit_battle_exam_secure` RPC SQL, database triggers, RLS policies. |
| **[business.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/business.md)** | **Business Model & Subscriptions** | Freemium vs Premium tier feature matrix, bKash & Nagad sequence diagram, subscription lifecycle status table (`trial`, `active`, `pending_verification`, `expired`, `cancelled`), pricing. |
| **[quality.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/quality.md)** | **Quality Assurance & Testing** | `flutter analyze` audit log (0 errors), complete `flutter test` inventory (8/8 unit tests passing for score calculator & BLoC), security audit checklist. |
| **[components.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/components.md)** | **Component Catalog** | Catalog of core reusable components (`SpringButton`, `CustomContainer`, `InfoRow`, `PremiumAvatarRing`, `CustomTextField`, `ErrorStateWidget`, `AppNotifier`) with props and code examples. |
| **[ai.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/ai.md)** | **AI Directives & Guidelines** | Mandatory rules for AI pair programmers, MCP dual DB migration sync directive, slash commands reference (`/goal`, `/schedule`, `/learn`). |

---

## 🚀 Role-Based Quick Navigation

- **For Flutter Developers**: Start with [engineering.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/engineering.md), [ui_ux.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/ui_ux.md), and [components.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/components.md).
- **For Backend & Database Engineers**: Read [backend.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/backend.md) and [quality.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/quality.md).
- **For Product Managers & QA Engineers**: Consult [project.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/project.md), [features.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/features.md), and [business.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/business.md).
- **For AI Coding Agents**: Follow [ai.md](file:///e:/Flutter/Flutter%20App/target_ace/docs/ai.md).
