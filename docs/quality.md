# TargetAce: Quality Assurance, Security & Performance Audit

---

## 🔍 1. Static Code Analysis (`flutter analyze`)

Static code analysis is executed via `flutter analyze` against the rules defined in `analysis_options.yaml`.

- **Command**: `flutter analyze`
- **Latest Audit Log Result**:
  ```text
  Analyzing target_ace...                                         
  No issues found! (ran in 104.1s)
  ```
- **Linter Status**: **0 Errors, 0 Warnings, 0 Lints**.

---

## 🧪 2. Automated Unit Test Suite (`flutter test`)

TargetAce contains automated unit tests covering domain calculation services and presentation BLoCs.

- **Command**: `flutter test`
- **Latest Suite Execution Result**:
  ```text
  00:00 +8: All tests passed!
  ```

### Unit Test Inventory & Assertions

#### 1. `test/features/battle/domain/services/battle_score_calculator_test.dart`
Tests the pure domain calculation service `BattleScoreCalculator.calculate(...)`:

1. **`should calculate 100.0 score when all questions are answered correctly`**:
   - Asserts: `correctCount == 4`, `wrongCount == 0`, `unansweredCount == 0`, `score == 100.0`.
2. **`should deduct negative marks for wrong answers correctly`**:
   - Asserts: 1 correct (+1.0), 2 wrong (-0.50), 1 unanswered (0.0) -> Raw score `0.50` out of `4.0` max = `12.5%`.
3. **`should clamp negative scores to 0.0 floor`**:
   - Asserts: 4 wrong answers (-1.00 raw score) clamps to `0.0%` (no negative final percentage).
4. **`should force fill unanswered questions when forceFillUnanswered is true`**:
   - Asserts: Unanswered entries are populated up to total question count with status `'unvisited'` or `'skipped'`.
5. **`should return 0.0 when questions list is empty`**:
   - Asserts: Zero-division guard returns `score == 0.0` without crashing.

#### 2. `test/features/battle/presentation/bloc/battle_bloc_test.dart`
Tests state management controllers for `BattleBloc`:

1. **`initial state should be BattleInitial`**:
   - Asserts: Initial state on instantiation is `isA<BattleInitial>()`.
2. **`should emit [BattleLoading, BattleActive] when BattleLoadRequested succeeds for an ongoing exam`**:
   - Asserts: Emits `BattleLoading` followed by `BattleActive` with active question countdown when valid exam & user cache exists.
3. **`should emit [BattleLoading, BattleError] when GetExams fails`**:
   - Asserts: Emits `BattleLoading` followed by `BattleError` carrying failure message when server RPC errors out.

---

## 🛡️ 3. Security Hardening & Audit Checklist

- [x] **Server-Side RPC Score Calculation**: Client-submitted raw scores are ignored. PostgreSQL function `submit_battle_exam_secure` evaluates correct options directly against database keys.
- [x] **Credential Cleanliness**: Removed all hardcoded secrets (`subscriptionSharedSecret`) from client configuration files.
- [x] **App Lifecycle Anti-Cheat**: Automatic exam auto-submission and disqualification (`disqualified: true`) triggered if Flutter app enters background (`paused`/`inactive`).
- [x] **Database Row Level Security (RLS)**: Enabled on all tables (`profiles`, `exams`, `questions`, `exam_submissions`, `leaderboards`).
