# TargetAce: Reusable Component Catalog & Widget Reference

---

## 🎨 1. Core UI Components (`lib/core/components`)

All components conform strictly to the Dark Obsidian design system.

### 1. `SpringButton`
- **File**: `lib/core/components/spring_button.dart`
- **Description**: Wraps clickable elements to provide spring physics scale feedback on tap (scales down to `0.96` on touch down).
- **Parameters**:
  - `onPressed` (`VoidCallback?`): Tap event callback.
  - `child` (`Widget`): Child widget to render inside the button.
  - `width` (`double?`): Optional explicit width (e.g. `double.infinity`).
  - `height` (`double?`): Optional explicit height (default `48.0`).
  - `color` (`Color?`): Fill color (defaults to `AppColors.primary`).

```dart
SpringButton(
  width: double.infinity,
  onPressed: () => print('Button tapped'),
  child: Text('Visit Website to Subscribe'),
)
```

---

### 2. `CustomContainer`
- **File**: `lib/core/components/custom_container.dart`
- **Description**: Standard card surface container styled with `AppColors.card` surface background, rounded corners, and optional subtle borders.
- **Parameters**:
  - `child` (`Widget`): Content widget.
  - `padding` (`EdgeInsetsGeometry?`): Internal padding (defaults to `EdgeInsets.all(16)`).
  - `margin` (`EdgeInsetsGeometry?`): External margin.
  - `borderRadius` (`double`): Border radius (default `16.0`).
  - `border` (`BoxBorder?`): Optional container border.

```dart
CustomContainer(
  padding: EdgeInsets.zero,
  child: Column(
    children: [
      InfoRow(icon: HugeIcons.strokeRoundedSmartPhone01, label: 'bKash Accepted', value: 'Local mobile banking'),
      const CustomDivider.dotted(),
      InfoRow(icon: HugeIcons.strokeRoundedClock01, label: 'Activation', value: 'Within 24 hours'),
    ],
  ),
)
```

---

### 3. `InfoRow`
- **File**: `lib/core/components/info_row.dart`
- **Description**: Renders structured metadata rows with an icon, title label, description value, and optional onTap callback.
- **Parameters**:
  - `icon` (`List<Object>` / IconData / HugeIcon): Icon to render on left.
  - `label` (`String`): Title text.
  - `value` (`String`): Description text.
  - `onTap` (`VoidCallback?`): Optional tap gesture listener.

---

### 4. `InfoValueItem`
- **File**: `lib/core/components/info_value_item.dart`
- **Description**: Compact key-value item used in grids and summary rows.
- **Parameters**:
  - `label` (`String`): Metadata label.
  - `value` (`String`): Value text.

---

### 5. `CustomTextField`
- **File**: `lib/core/components/custom_text_field.dart`
- **Description**: Styled text input field matching `AppColors` theme tokens and `AppFonts` typography.
- **Parameters**:
  - `controller` (`TextEditingController?`): Form controller.
  - `hintText` (`String?`): Placeholder hint.
  - `prefixIcon` (`Widget?`): Leading icon.
  - `obscureText` (`bool`): Toggle password masking.

---

### 6. `PremiumAvatarRing`
- **File**: `lib/core/components/premium_avatar_ring.dart`
- **Description**: Displays a gold/primary glowing ring around the user avatar if `isPremium` is true.
- **Parameters**:
  - `child` (`Widget`): Inner avatar image widget.
  - `isPremium` (`bool`): Flag to toggle premium ring gradient.
  - `size` (`double`): Diameter of the ring (default `40.0`).

---

### 7. `CustomDivider`
- **File**: `lib/core/components/custom_divider.dart`
- **Description**: Custom divider line with standard solid and `CustomDivider.dotted()` factory constructors.

---

## 🧩 2. Shared Widgets (`lib/core/shared/widgets`)

- **`GradientBackground`**: Full-screen scaffold background providing the Dark Obsidian radial gradient.
- **`InlineErrorWidget`**: Rendered inline above action buttons when forms or state contain inline error messages.
- **`EmptyStateWidget`**: Standard empty placeholder containing an illustration asset, header title, message, and action retry button.
- **`ErrorStateWidget`**: Comprehensive full-screen error display handling `Network`, `Server`, `NotFound`, and `BotProtection` error types with WhatsApp support button.
- **`AppNotifier`**: Unified SnackBar system providing colored banners for `MessageType.success`, `MessageType.warning`, and `MessageType.error`.
- **`Loader`**: Centered circular loading indicator styled with `AppColors.primary`.
- **`FadeWaveAnimation`**: Micro-animation component that pulses opacity during asynchronous background data fetching.
