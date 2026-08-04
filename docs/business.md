# TargetAce: Business Model, Subscriptions & Monetization

---

## 💼 1. Monetization Strategy

TargetAce employs a **Freemium & Micro-Subscription Model** optimized for Bangladeshi students:

| Feature / Access Tier | Free Tier | Premium Tier (BDT 50–100 / mo) |
| :--- | :---: | :---: |
| **Daily 9:00 PM Live Battle Exam** | ✅ Included (1/day) | ✅ Included |
| **Instant Score & Percentile** | ✅ Included | ✅ Included |
| **National Rank (Global/Group)** | ❌ Limited | ✅ Full Access |
| **3D Podium Display** | ❌ Masked | ✅ Full Access |
| **Detailed Question Explanations** | ❌ Locked | ✅ Full Access |
| **Practice Hub (Subject/Topic Quizzes)** | ❌ Restricted | ✅ Unlimited Access |
| **Bookmarking & Error Reporting** | ✅ Included | ✅ Included |

---

## 💳 2. Payment Flow & Mobile Banking Integration

TargetAce natively accommodates Bangladesh's Mobile Financial Services (MFS)—**bKash** and **Nagad**:

```mermaid
sequenceDiagram
    autonumber
    actor Candidate as Student Candidate
    participant App as TargetAce App
    participant Storage as SharedPreferences / Supabase
    actor Admin as Admin Web Panel

    Candidate->>App: Opens Subscription Page
    App->>Storage: Reads active status
    Storage-->>App: Status = 'expired' / 'none'
    App->>Candidate: Displays bKash/Nagad Merchant Details
    Candidate->>Candidate: Sends money via bKash/Nagad USSD or App
    Candidate->>App: Submits Sender Phone & Transaction ID (TxID)
    App->>Storage: Inserts payment record (status = 'pending')
    Storage-->>App: Profile status = 'pending_verification'
    App->>Candidate: Shows "Payment Under Review" Banner
    Admin->>Storage: Validates TxID in Admin Panel & Approves
    Storage-->>App: Profile status = 'active'
    App->>Candidate: Grants Full Premium Access
```

---

## 🔄 3. Subscription Status Lifecycles

The subscription lifecycle manages all candidate states within `UserLocalDataSource` and `profiles`:

```mermaid
stateDiagram-v2
    [*] --> none: New User Register
    none --> trial: Claim 7-Day Free Trial
    trial --> expired: 7 Days Elapsed
    
    none --> pending_verification: Submit TxID
    expired --> pending_verification: Submit TxID
    
    pending_verification --> active: Admin Approves Payment
    pending_verification --> expired: Admin Rejects Payment
    
    active --> expired: Plan Duration Expires
    active --> cancelled: Plan Cancelled
    cancelled --> active: Reactivated
```

### Complete Status Code Table

| Status String | UI Header Text | Main Button Action | Navigation Target |
| :--- | :--- | :--- | :--- |
| `'trial'` | Active Trial | Enter Live Arena | Home Arena (`/dashboard`) |
| `'active'` | Premium Active | Enter Live Arena | Home Arena (`/dashboard`) |
| `'pending_verification'` | Payment Under Review | Check Verification Status | Stay on Activation Page |
| `'pending'` | Payment Under Review | Check Verification Status | Stay on Activation Page |
| `'expired'` | Renew Your Subscription | Renew Subscription on Website | Launch External Website |
| `'cancelled'` | Reactivate Plan | Reactivate Plan on Website | Launch External Website |
| `'none'` | Premium Access | Visit Website to Subscribe | Launch External Website |

---

## 💬 4. WhatsApp Pre-Filled Support Protocol

If a candidate experiences payment issues or verification delays, clicking "Contact Support" on the activation page or error widget launches WhatsApp with pre-formatted diagnostic telemetry:

```dart
final message = '''
Assalamu Alaikum,

I am using TargetAce app. I need help regarding my subscription / account.

• Name: $userName
• User ID: $userId
• Plan: ${plan.isNotEmpty ? plan : 'No Active Plan'}
• App Version: ${AppConfig.appVersion}

My issue:
(Please write here)

Thank you.
''';
```
- **Generated Link**: `https://wa.me/8801700000000?text=<ENCODED_URI_COMPONENT>`
