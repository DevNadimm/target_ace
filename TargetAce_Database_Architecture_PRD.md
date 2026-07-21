# PRD: TargetAce Database Architecture Improvements

**Document Version:** 1.0
**Project:** TargetAce
**Module:** Database Architecture
**Author:** OpenAI
**Status:** Proposed
**Priority:** High

---

# 1. Objective

Improve the current TargetAce database architecture to support long-term scalability, AI-powered question generation, analytics, multiple competitive exam categories, and millions of question records without requiring future database redesign.

The current architecture is production-ready for MVP but lacks several normalized entities required for long-term growth.

---

# 2. Current Situation

The existing database already contains:

- Authentication
- Profiles
- Onboarding
- Battle Groups
- Questions
- Exams
- Exam Submissions
- Subscription
- Promo Codes
- Announcements

Strengths:

- UUID-based architecture
- Proper many-to-many Exam ↔ Question relationship
- JSONB answer storage
- Flexible onboarding system
- Battle group architecture
- Rich user profile

However, the system still mixes educational hierarchy into a single layer, making future expansion increasingly difficult.

---

# 3. Goals

This update aims to achieve:

- Proper educational hierarchy
- Better database normalization
- AI-ready structure
- Easier analytics
- Faster querying
- Future expansion to multiple exam categories

Supported future exams:

- BCS
- University Admission
- HSC
- SSC
- Medical
- Engineering
- Bank Jobs
- Government Jobs
- IELTS
- GRE
- Any future examination

---

# 4. Functional Requirements

## FR-1 Subject Management

### Problem

Questions currently belong only to onboarding groups.

Example:

BCS contains

- Bangla
- English
- Math
- ICT
- Science

There is no way to determine which subject a question belongs to.

---

### Solution

Create a new table.

subjects

Fields

- id
- goal_id
- name
- description
- icon_name
- display_order
- created_at

Questions should reference

subject_id

instead of relying on tags.

---

### Benefits

- Subject Practice
- Subject Leaderboard
- AI Exam Generation
- Subject Analytics
- Subject Progress

Priority

HIGH

---

# FR-2 Topic Management

### Problem

Questions are stored directly under subjects.

This prevents chapter-wise practice.

---

### Solution

Create

topics

Fields

- id
- subject_id
- name
- description
- display_order

Questions

topic_id

---

### Benefits

- Chapter Practice
- Weak Topic Detection
- Personalized Recommendation
- AI Exam Generation
- Completion Tracking

Priority

HIGH

---

# FR-3 Question Metadata

Current question schema lacks important metadata.

Add

- created_by
- updated_by
- reviewed_by
- reviewed_at
- version
- is_active
- estimated_time
- ai_generated
- source
- reference
- quality_score

---

Benefits

- Audit trail
- AI filtering
- Version control
- Content moderation

Priority

High

---

# FR-4 Difficulty Improvements

Replace

Easy

Medium

Hard

with

difficulty_level

Values

1

2

3

4

5

---

Benefits

Allows weighted random question generation.

Priority

Medium

---

# FR-5 Exam Type

Current exam table does not distinguish exam categories.

Add

exam_type

Values

- Live
- Daily
- Practice
- Mock
- Premium
- Custom

---

Benefits

Simple filtering.

Future proof.

Priority

High

---

# FR-6 Exam Visibility

Add

status

Values

Draft

Scheduled

Live

Completed

Cancelled

Additional fields

publish_result_at

visible_at

---

Benefits

Admin can schedule results.

Priority

Medium

---

# FR-7 Exam Question Metadata

Update exam_questions table.

Current

- exam_id
- question_id

New

- display_order
- marks
- negative_marks

---

Benefits

Maintain fixed order.

Different marks per question.

Priority

Medium

---

# FR-8 Submission Metadata

Current submissions store only answers.

Add

- started_at
- completed_at
- time_taken_seconds
- device
- app_version
- ip_address
- is_auto_submitted

---

Benefits

- Cheat detection
- Performance analytics
- Crash recovery

Priority

Medium

---

# FR-9 Leaderboard Cache

Create

leaderboards

Fields

- exam_id
- user_id
- score
- rank
- updated_at

---

Benefits

Very fast ranking.

Suitable for thousands of concurrent users.

Priority

Medium

---

# FR-10 Subscription Plans

Current subscription stores

plan_name

plan_id

Create

plans

Fields

- id
- name
- duration
- price
- features
- is_active

Subscription references

plan_id

---

Benefits

Single source of truth.

Priority

Medium

---

# FR-11 Notification System

Create

notifications

Fields

- id
- user_id
- title
- body
- type
- is_read
- created_at

---

Benefits

Exam reminders

Battle reminders

Subscription reminders

Announcements

Priority

Medium

---

# FR-12 Battle Group Improvements

Add

- is_public
- is_active
- max_members

Member count should be automatically updated using database triggers.

Priority

Medium

---

# FR-13 AI Ready Metadata

Questions should include

- ai_generated
- source
- reference
- estimated_time
- quality_score

Purpose

Improve AI-generated exams and recommendation quality.

Priority

Future

---

# 5. Non-Functional Requirements

## Scalability

Support

- Millions of questions
- Millions of submissions
- Thousands of simultaneous battles

---

## Performance

Leaderboard response

<100ms

Question loading

<200ms

Submission

<500ms

---

## Maintainability

- Proper normalization
- Minimal duplicated data
- Easy migrations
- Easy feature expansion

---

## Security

- Row Level Security
- UUID identifiers
- Audit fields
- Soft deletion instead of hard delete

---

# 6. Expected Database Hierarchy

Goal

↓

Subject

↓

Topic

↓

Question

↓

Exam

↓

Submission

↓

Leaderboard

---

# 7. Expected Benefits

After implementing these improvements, TargetAce will support:

✅ Subject-wise Practice

✅ Topic-wise Practice

✅ AI Question Generation

✅ AI Personalized Learning

✅ Adaptive Difficulty

✅ Multiple Competitive Exam Categories

✅ Better Analytics

✅ Faster Queries

✅ Future Expansion Without Schema Redesign

---

# 8. Implementation Priority

## Phase 1 (Before Public Launch)

- Subjects
- Topics
- Question metadata
- Exam type
- Exam question metadata
- Plans table

---

## Phase 2 (Growth)

- Notifications
- Leaderboard cache
- Submission metadata

---

## Phase 3 (Scale)

- AI metadata
- Adaptive recommendation
- Topic mastery
- Smart exam generation
- Advanced analytics

---

# 9. Success Metrics

The update will be considered successful when:

- Subject-based exam generation requires no manual filtering.
- Topic-wise practice is fully supported.
- New competitive exams can be added without schema redesign.
- Leaderboards scale efficiently for large concurrent battles.
- AI can generate balanced exams using structured subject and topic relationships.
- Database remains normalized, maintainable, and performant as the platform grows.

---

# Conclusion

The existing ERD provides a strong MVP foundation, but introducing structured educational entities (Subjects and Topics), richer metadata, normalized reference tables, and AI-ready fields will transform TargetAce into a scalable competitive exam platform capable of supporting diverse exam ecosystems and long-term growth without major architectural changes.
