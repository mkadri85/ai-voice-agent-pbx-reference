# Sera Call-Flow Options & Phased Rollout
*For management discussion · the hotel AI Voice Agent (Sera)*

## Purpose
Three ways the AI assistant **Sera** can sit in the hotel's phone flow — from lowest-risk to full
front-door. **Agreed rollout order: start with Option 2 → then Option 3 → then Option 1 (end-goal).**
Our middleware + Sera support all three; what changes between them is mostly **how the Alcatel routes
calls to Sera** and **how much ElevenLabs capacity we need.**

---

## The three options at a glance

| | **Option 2 — Human-first / overflow** *(start here)* | **Option 3 — Menu option** *(next)* | **Option 1 — AI front door** *(end-goal)* |
|---|---|---|---|
| Caller experience | Reception rings first; Sera answers only if no one picks up (≈3 rings) or after hours | Alcatel menu: "press 2 to speak to our assistant" — caller opts in | Sera greets **every** caller, answers, and routes to a human on request |
| Who hits the AI | Only missed / after-hours calls | Only callers who choose it | **Everyone** |
| Main benefit | Captures missed calls (biggest proven win), almost no risk | Builds usage + confidence, still opt-in | Most modern experience; deflects routine calls |
| Risk / blast radius | Tiny — only unanswered calls | Small — only opt-in callers | **High — any AI hiccup affects all callers** |
| ElevenLabs capacity needed | Low | Low–medium | **High — plan upgrade required (concurrency)** |
| Extra must-haves | Fallback (already designed) | Fallback | Fallback **+ instant "press 0" human escape + sized plan + privacy sign-off** |

---

## Agreed phased rollout

**Phase 1 — Option 2 (Human-first / overflow & after-hours).**
Reception answers as today; if a call goes unanswered after ~3 rings, or comes in after hours, the
Alcatel forwards it to Sera. Lowest risk, immediate value (no more missed calls), tiny AI load. Ideal
to prove Sera in real use.

**Phase 2 — Option 3 (Menu option, "press 2").**
Once Phase 1 is proven, add an opt-in menu choice so callers who want the assistant can reach her
directly. More usage, still opt-in, still low risk.

**Phase 3 — Option 1 (AI front door).**
The end-goal: Sera greets everyone and routes to humans on request, with an instant "press 0 for
reception" escape. Switched on only **after** the ElevenLabs plan is sized for peak simultaneous calls,
the fallback is proven in Phases 1–2, and the hotel privacy sign-off is in place.

---

## What stays the SAME across all three (already built / designed)
- **The middleware logic.** However the call arrives, Asterisk does the same thing: try Sera → if she's
  unavailable/slow, **fall back to Reception automatically.** One dialplan covers all three options.
- **Transfers to humans = Alcatel dial-back.** When Sera hands a caller to a department, the middleware
  rings the real extension inside the Alcatel — reliable, and identical in every option.
- **The safety rule.** AI failure never breaks normal phones; callers always reach a human.
- **Sera herself** — same agent, knowledge base, and privacy settings (recording off, 0-day retention).

## What CHANGES per option (and who sets it)
| Item | Owner | Opt 2 | Opt 3 | Opt 1 |
|---|---|---|---|---|
| Alcatel routing to Sera | ALE vendor / hotel telecom (gate G7) | Forward-on-no-answer + after-hours rule | IVR "press 2" branch | Main number → middleware first |
| ElevenLabs plan / concurrency | Project + EL admin (gate G5) | Starter OK | Starter–small | **Upgrade to cover peak simultaneous calls** |
| "Press 0 / say reception" instant escape | Us (Sera prompt + transfer) | nice-to-have | recommended | **required** |
| Privacy sign-off (room #/requests to AI) | Hotel compliance (gate G6) | required | required | **required** |

## How to turn the AI on / off (all options)
- **Manual:** the Alcatel entry point for Sera (the overflow rule / menu branch / main-number route)
  is re-pointed back to Reception → AI off in seconds, nothing else affected.
- **Automatic:** if Sera/ElevenLabs is down, the middleware sends callers to Reception on its own.

## Readiness summary (our side)
- **Middleware (Asterisk):** ✅ ready/adaptable for all three — same "try Sera → fallback" dialplan
  (templates staged). No rework between phases; only the Alcatel entry config differs.
- **Sera (ElevenLabs):** built (RAG + full-service prompt + privacy). Pending: **SIP trunk** (dashboard),
  and for Phase 3 the **instant-escape** wording + a **bigger plan**.
- **Gating items for the end-goal (Option 1):** G5 plan/concurrency upgrade · G6 privacy sign-off ·
  G7 Alcatel front-door routing · proven fallback from Phases 1–2.

## Decisions for management
1. Approve the phased order (2 → 3 → 1) and the trigger to move between phases (e.g. "X weeks stable").
2. Approve the **privacy posture** (Sera collects room #/requests → sent to ElevenLabs' cloud) — gate G6.
3. Budget the **ElevenLabs plan upgrade** needed before Option 1 (front-door concurrency).
4. Confirm the **Alcatel routing changes** with the ALE vendor for each phase (gate G7).
