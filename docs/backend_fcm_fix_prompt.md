# Fix FCM Push Notification + Conversation API Bugs — UJobs Backend

You are working on the UJobs backend: the FCM push-notification sender and the `/conversations` REST API. Several bugs have been confirmed by capturing live payloads on a real device. Fix all of them below.

Existing API endpoints relevant to this fix (so you know what data each side ultimately needs to supply ids for):
- `GET /api/v1/mobile/employer/applicants/:id` — returns applicant/application contact details (needs the **application id**)
- `GET /api/v1/mobile/seeker/jobs/:id` — returns job + company details (needs the **job id**)

---

## Bug 1 — `sender_name` in `type: "message"` push is not resolved per actual sender

**This is the highest priority bug — confirmed with two real payloads from the same device/conversation, captured a few hours apart.**

Logged in as **employer** (job seeker sends a message to the employer):
```json
{"user_id":46,"screen":"chat_screen","created_at":"2026-07-11T17:31:22.284Z","sender_name":"MD AZAD HOSSAIN TUTUL","sender_avatar":null,"type":"message","sender_id":47,"chat_id":14}
```

Logged in as **job seeker** (employer/company sends a message to that seeker, same conversation, `chat_id: 14`):
```json
{"user_id":47,"screen":"chat_screen","created_at":"2026-07-11T11:56:59.531Z","sender_name":"MD AZAD HOSSAIN TUTUL","sender_avatar":null,"type":"message","sender_id":46,"chat_id":14}
```

Note `sender_id` correctly flips between `46` and `47` depending on who actually sent the message — that part works. But `sender_name` is **identical in both pushes** ("MD AZAD HOSSAIN TUTUL", which is the job seeker's real name) even though in the second payload `sender_id: 46` is the **employer/company account**, not the seeker. The employer's push should show the **company name** (e.g. "IT ACCESS LTD"), not the seeker's personal name.

**Root cause:** `sender_name` is not being looked up fresh from the message's actual `sender_id` at send time. It looks like it's resolved once from a stale/wrong source (e.g. the conversation's original initiator, or a cached value) and reused for every push in that conversation, regardless of who really sent the latest message.

**Required fix:**
1. For every `message`-type push, resolve `sender_name` (and `sender_avatar`) **fresh, from the actual `sender_id` of that specific message**, not from a cached/initial value.
2. When the resolved `sender_id` is an **employer/company account**, `sender_name` must be the **company profile name** (same field used elsewhere for `company_name`), and `sender_avatar` must be the **company logo** — not the employer's personal user name/avatar.
3. When the resolved `sender_id` is a **job seeker**, keep using the seeker's personal name/avatar (that direction already works correctly).
4. Verify the fix against a real conversation where messages alternate both directions — confirm `sender_name`/`sender_avatar` changes correctly on every single push, matching whoever actually sent that specific message.

## Bug 2 — `application_id` sent as `app_id`

The intended payload key for this notification is `application_id`. Live payloads instead send the key `app_id`. The app currently has a workaround accepting both, but the backend should emit the correct key: `application_id`.

**Required fix:** rename the field key from `app_id` to `application_id` in the `new_application` push payload builder (search wherever this payload is constructed, likely near job-application creation logic). Full intended payload:
```json
{
  "type": "new_application",
  "screen": "applicant_profile",
  "employer_id": "employer_id",
  "application_id": "application_id",
  "job_id": "job_id"
}
```

## Bug 3 — Verify `job_id` present in `job_approved` / `application_submitted` payloads

Users report that tapping these notification types sometimes fails to open job details — consistent with `job_id` being absent.

**Required fix:**
1. Log/dump one real payload for `type: "job_approved"` and one for `type: "application_submitted"`.
2. Confirm `job_id` is present and valid in both. Intended shapes:
```json
{
  "type": "job_approved",
  "screen": "job_details",
  "employer_id": "employer_id",
  "job_id": "job_id"
}
```
```json
{
  "type": "application_submitted",
  "screen": "application_details",
  "application_id": "application_id",
  "job_id": "job_id",
  "employer_id": "employer_id",
  "seeker_id": "seeker_id"
}
```
3. If `job_id` is missing in either, fix the payload builder to always include it.

## Bug 4 — `job_id` / `application_id` missing from `type: "message"` push AND from `GET /conversations`, breaking the chat contact-info panel

The mobile app's chat screen has a "menu" button that opens a bottom sheet showing the other party's contact info (name, email/phone, company details, or applicant details). To populate that sheet, the app needs to call:
- `GET /api/v1/mobile/seeker/jobs/:id` on the seeker side — requires **`job_id`**
- `GET /api/v1/mobile/employer/applicants/:id` on the employer side — requires **`application_id`**

Neither id is currently available to the app at the two most common places chat gets opened from:
1. The `message` push payload itself (see Bug 1's example payloads above — no `job_id` or `application_id` key at all, only `chat_id`, `sender_id`, `user_id`).
2. The `GET /conversations` list response — it has no job/application linkage on a conversation at all today.

Because of this, when a user opens chat from the Messages inbox tab or from tapping a push notification (as opposed to opening chat from a job-detail or applicant-detail screen, which already knows these ids), the contact-info bottom sheet has nothing to fetch from and shows name/avatar only — no email, phone, or company/applicant details.

**Required fix:**
1. Add `job_id` and `application_id` fields to the `type: "message"` FCM push payload (in addition to the existing `chat_id`, `sender_id`, `sender_name`, `sender_avatar`, `user_id`). Populate whichever is relevant to the conversation (a conversation tied to a specific job application should be able to supply both — the job it's about, and the application record connecting the two parties). Full intended payload:
```json
{
  "type": "message",
  "screen": "chat_screen",
  "chat_id": "conversation_id",
  "sender_id": "sender_user_id",
  "sender_name": "sender_name",
  "sender_avatar": "sender_avatar_url",
  "job_id": "job_id",
  "application_id": "application_id"
}
```
2. Add the same `job_id` and `application_id` fields to each conversation object returned by `GET /conversations`, so the app can resolve these ids even without a push notification (e.g. opening the Messages tab directly).
3. Confirm these ids are correct per conversation — i.e., `job_id` is the job this chat is about, and `application_id` is the specific application connecting the seeker and employer in that conversation.

## Bug 5 — Employer/company email and phone missing from job details response

The seeker-facing job details endpoint (`GET /api/v1/mobile/seeker/jobs/:id`) response's company object does not include `email` or `phone`. The app has no way to display these fields today because the response simply doesn't contain them — only `name, logo, website, description, industry, size, location, is_verified, founded, linkedin_url, facebook_url` (or equivalent) come back, so seekers can't see a way to contact the company directly (by email/phone) from the job detail screen or the chat contact-info sheet.

**Required fix:**
1. Check whether the employer/company record stores an email and phone number (likely yes — company profile or employer account contact info).
2. Add `email` and `phone` fields to the company/employer object embedded in `GET /seeker/jobs/:id`'s response (and any other job-details endpoint returning company info).
3. Match existing naming convention in that response (snake_case, e.g. `email`, `phone` or `phone_number` — check what the rest of the payload already uses).

---

## Deliverable

For each of the 5 bugs above, report:
1. What was actually wrong in the current code (file/function/query).
2. The fix applied.
3. One real example JSON payload (post-fix) for each affected notification type / API response, so it can be verified against it. For Bug 1 specifically, provide a two-message example (one from each direction of the same conversation) showing `sender_name`/`sender_avatar` now resolving correctly per actual sender.
