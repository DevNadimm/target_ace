# Product Requirements Document (PRD)

| Item | Details |
| :--- | :--- |
| **Project Name** | TargetAce: Live Battle Exams |
| **Version** | 1.0 (MVP) |
| **Status** | Draft |
| **Target Platforms** | Android (Student Client), Flutter Web (Admin Panel) |
| **Key Tech Stack** | Flutter, Supabase (Auth, DB, Real-time RPC) |

---

## 1. Introduction & Executive Summary

### 1.1 Project Vision
`TargetAce` হলো একটি রিয়েল-টাইম, কম্পিটিটিভ পরীক্ষা প্ল্যাটফর্ম, যা বাংলাদেশে (এবং পরবর্তীতে বিশ্বব্যাপী) নির্দিষ্ট ক্যারিয়ার ও একাডেমিক গোল (Niches) অনুযায়ী শিক্ষার্থীদের সমমনা প্রতিযোগীদের সাথে "লাইভ ব্যাটল" করার সুযোগ দেয়। এটি সনাতন পড়াশোনাকে গেমের মতো আনন্দদায়ক এবং সিরিয়াস প্রতিযোগিতামূলক করে তোলে।

### 1.2 The Problem
* শিক্ষার্থীরা পরীক্ষার আগে একঘেয়েমি অনুভব করে।
* প্রচলিত কুইজ অ্যাপে রিয়েল-টাইম প্রতিযোগিতার অভাব।
* বাংলাদেশের লোকাল নিশ (যেমন: BCS) অনুযায়ী মানসম্মত লাইভ প্ল্যাটফর্ম নেই।
* অনলাইন টেস্টে প্রচুর চিটিং হয়।
* সনাতন পেমেন্ট মেথড (Credit Card) বাংলাদেশের শিক্ষার্থীদের জন্য কঠিন।

### 1.3 The Solution (TargetAce)
* **Segmented Targets:** BCS, ভর্তি পরীক্ষা, বা ক্লাস ১১ অনুযায়ী আলাদা জোন।
* **Live Battles:** প্রতিদিন একটি নির্দিষ্ট সময়ে হাজার হাজার স্টুডেন্ট একসাথে ১টি পরীক্ষায় অংশ নেয়।
* **Dynamic Leaderboard:** শুধুমাত্র একই টার্গেটের স্টুডেন্টদের মধ্যে রিয়েল-টাইম র্যাংকিং।
* **Anti-Cheat System:** পরীক্ষা চলাকালীন অ্যাপ মিনিমাইজ বা ব্যাকগ্রাউন্ডে নিলে অটো-সাবমিট।
* **Local Payment:** বিকাশ/নগদ ম্যানুয়াল TxID ভেরিফিকেশনের মাধ্যমে সাবস্ক্রিপশন।

---

## 2. Target Audience & Personas

### 2.1 Target Audience
* **বাংলাদেশে:** BCS ক্যান্ডিডেট, ঢাকা ইউনিভার্সিটি ও অন্যান্য পাবলিক বিশ্ববিদ্যালয়ের ভর্তি পরীক্ষার্থী, একাদশ-দ্বাদশ শ্রেণীর শিক্ষার্থী।
* **গ্লোবালি (Scalability):** SAT, GRE, IELTS পরীক্ষার্থী (পরবর্তী ধাপে)।

### 2.2 Personas (MVP)
* **রাহাত (BCS ক্যান্ডিডেট):** বয়স ২৫। তার সারাদিনের পড়াশোনার শেষে রাত ৯টায় ১টি সিরিয়াস মডেল টেস্ট দরকার, যেখানে সে দেখতে পারে পুরো বাংলাদেশে তার র্যাংক কত।
* **সাদিয়া (HSC ক্যান্ডিডেট):** বয়স ১৭। তার ক্লাস ১১ এর ফিজিক্স বা কেমিস্ট্রির ওপর প্রতিদিনের লাইভ কুইজ দরকার, যাতে পরীক্ষার প্রস্তুতি আনন্দদায়ক হয়।

---

## 3. Core MVP Features (Scope)

*ফিচারগুলোকে Priority অনুযায়ী সাজানো হয়েছে (P0 = Critical, P1 = Important).*

### Module 1: Student Android App

| Feature ID | Feature Name | Priority | Description |
| :--- | :--- | :--- | :--- |
| **F-MOB-01** | **Dynamic Onboarding** | P0 | সাইন-আপের পর ইউজার তার "টার্গেট গোল" (e.g., BCS 46th) সিলেক্ট করবে। এটি তার হোম স্ক্রিনের থিম ও কন্টেন্ট নির্ধারণ করবে। |
| **F-MOB-02** | **Niche Dashboard** | P0 | শুধুমাত্র ইউজারের সিলেক্ট করা টার্গেটের জন্য নির্ধারিত আজকের লাইভ পরীক্ষার কাউন্টডাউন টাইমার দেখাবে। |
| **F-MOB-03** | **Live Battle Engine** | P0 | রিয়েল-টাইম টাইমার-সিঙ্ক করা MCQ কুইজ। সময় শেষ হলে অটো-সাবমিট। নেগেティブ মার্কিং এক্সাম অনুযায়ী প্রযোজ্য। |
| **F-MOB-04** | **Anti-Cheat Monitor** | P0 | পরীক্ষা চলাকালীন ইউজার অ্যাপ ব্যাকগ্রাউন্ডে নিলে বা মিনিমাইজ করলে পরীক্ষা অটো-সাবমিট হবে এবং ইউজার disqualify হবে। |
| **F-MOB-05** | **Isar/Hive Cache** | P1 | পরীক্ষার প্রশ্নগুলো পরীক্ষা শুরুর ৬০ সেকেন্ড আগে সিকিউর লোকাল ক্যাশে প্রি-লোড হবে, যাতে স্লো ইন্টারনেটেও পরীক্ষা স্মুথ হয়। |
| **F-MOB-06** | **Niche Leaderboard** | P0 | পরীক্ষা শেষ হওয়ার ১ মিনিটের মধ্যে শুধুমাত্র একই টার্গেটের স্টুডেন্টদের মধ্যে Rank, Score, Time Taken সহ লিডারবোর্ড দেখাবে। |
| **F-MOB-07** | **BD Local Paywall** | P0 | প্রিমিয়াম ফিচার দেখতে চাইলে বিকাশ/নগদ নাম্বার ও TxID বসানোর স্ক্রিন। |

### Module 2: Admin Flutter Web Panel

| Feature ID | Feature Name | Priority | Description |
| :--- | :--- | :--- | :--- |
| **F-WEB-01** | **Target & Exam Manager** | P0 | নতুন টার্গেট তৈরি করা, এক্সাম শিডিউল করা, নেগেティブ মার্কিং লজিক সেট করা। |
| **F-WEB-02** | **Bulk Question Import** | P0 | অ্যাডমিন ওয়েবসাইটে CSV/Spreadsheet ফাইল আপলোড করে এক ক্লিকে হাজার হাজার MCQ প্রশ্ন ডাটাবেজে পুশ করবে। |
| **F-WEB-03** | **Payment Verifier** | P0 | স্টুডেন্টদের পাঠানো বিকাশ/নগদ TxID এবং অ্যামাউন্ট অ্যাডমিন প্যানেলে দেখাবে। অ্যাডমিন approve করলে ইউজারের `is_premium` স্ট্যাটাস true হবে। |

---

## 4. Monetization Strategy

### 4.1 Subscription Model (MVP)
* **Free Tier:** প্রতিদিনের ১টি লাইভ ব্যাটেলে অংশ নেওয়া সম্পূর্ণ ফ্রি।
* **Premium Tier:** বিগত দিনের পরীক্ষার প্রশ্নের বিস্তারিত ব্যাখ্যা (Explanations), সাবজেক্ট-ভিত্তিক প্র্যাকটিস কুইজ এবং স্পেশাল মেগা-টেস্টে অংশ নেওয়ার সুযোগ।
* **Price:** ৫০ - ১০০ BDT প্রতি মাসে (Micro-subscription)।

---

## 5. Technical & Non-Functional Requirements

| Requirement Category | Description |
| :--- | :--- |
| **State Management** | BLoC বা Riverpod (Scale ও Performance মেইনটেইন করার জন্য)। |
| **Database** | Supabase (PostgreSQL) - Relational DB structure with foreign key linking (CASCADE setup)। |
| **Real-time Core** | Supabase Real-time (WebSockets) লিডারবোর্ড আপডেটের জন্য এবং সিঙ্ক্রোনাইজড টাইমারের জন্য RPC। |
| **Security** | Supabase Row Level Security (RLS) যাতে স্টুডেন্টরা অন্য কারো ডেটা দেখতে বা এডিট করতে না পারে। |
| **Scalability** | PostgreSQL Composite Indexes মেইনটেইন করতে হবে লিডারবোর্ডের `WHERE disqualified = FALSE` কোয়েরিতে। |
| **Timezone Management**| সব এক্সাম শিডিউল UTC টাইমজোনে ডাটাবেজে থাকবে। Flutter অ্যাপ DateTime.toLocal() ব্যবহার করে ইউজারের লোকাল টাইমে কাউন্টডাউন দেখাবে। |

---

## 6. Development Pipeline & Key Decisions

### Critical Decision: 1 Day = 1 Exam (Niche Focus)
MVP ভার্সনে প্রতি টার্গেটের জন্য দিনে শুধুমাত্র ১টি বড় পরীক্ষা হবে (যেমন: বিসিএস রাত ৯টায়, ক্লাস ১১ রাত ৮টায়)। এটি আমাদের সার্ভার প্রেশার কমাবে এবং পরীক্ষার্থীদের সিরিয়াসনেস বৃদ্ধি করবে।

### Roadmap Summary
1. **Supabase Schema & Web Admin Panel:** কন্টেন্ট ইম্পোর্ট করার রাস্তা রেডি করা।
2. **Android Live Screen Logic:** অ্যান্টি-চিট অবজারভার এবং রিয়েল-টাইম কাউন্টডাউন সিঙ্ক্রোনাইজেশন।
3. **BD Payment Flow & Paywall:** বিকাশ/নগদ ম্যানুয়াল TxID ভেরিফিকেশন।

---

## 7. Success Metrics (KPIs)
* **DAU (Daily Active Users):** প্রতিদিন কতজন স্টুডেন্ট লাইভ ব্যাটেলে অংশ নিচ্ছে।
* **Niche Retention:** BCS ক্যান্ডিডেটরা ১ সপ্তাহ পরীক্ষা দেওয়ার পর পরের সপ্তাহেও ফিরে আসছে কিনা।
* **Conversion Rate:** মোট ফ্রি ইউজারের কত শতাংশ বিকাশ/নগদ পেমেন্ট করে প্রিমিয়াম সাবস্ক্রিপশন নিচ্ছে।

---

> **Peer Advice on Anti-Cheat:** অ্যান্টি-চিট অবজারভারটি খুবই লিন (Lean) এবং ফাস্ট রাখতে হবে। এটি যেন ডাটাবেজে বার বার রিকোয়েস্ট পাঠিয়ে পরীক্ষা চলাকালীন স্লো ইন্টারনেট ইউজারের লেটেন্সি বৃদ্ধি না করে। disqualification লজিক ব্যাকএন্ডে (DB level) মেইনটেইন করো।
