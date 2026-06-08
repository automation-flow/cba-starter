---
name: meeting-prep
description: Build a full client profile before a meeting. Give a name + company, get an 8-part profile with cited sources. An example of an Act-layer agent.
---

# Meeting-Prep

An example agent, so you can see what one looks like. Give it a person's name and
their company, get a meeting-ready profile instead of an hour of prep. Every claim
has a source.

## Run it
Input: a person's name + their company.

1. Read this brain first. Check wiki/ for any page on the person, the company, or
   past meetings, and fold what's there into the profile.
2. Validate on LinkedIn that the person works there now, in that role. If you
   can't confirm it, say so. Don't guess.
3. Research the company live: what they do, products, stack, and news from the
   last 12 months. Cite a source for every claim.
4. Read the last 60 days of the person's posts: recurring themes, tone, and
   2-3 ice breakers to open with.
5. Assemble the profile, 8 parts:
   - Key contacts: name, role, place in the decision
   - Company: site, industry, size, products
   - Systems: CRM/ERP, tools, integration constraints
   - Challenges and pains
   - Goals: short term and long term
   - Budget and timeline
   - Decision structure: who signs off
   - Research and talking points: findings plus ice breakers

## Rules
- Every claim has a cited source.
- Anything you can't verify in public: mark "to verify in the discovery call".
  Never invent facts, numbers, or quotes.
- Save the result as wiki/person/<name>.md, linked with [[wikilinks]] to the company.
- If the name is in Hebrew, write the profile in Hebrew.

This is the shape of an Act-layer agent: it reads the Brain, does focused work,
and writes back to the Brain. Copy it to build your own.

Want the production-grade version, with the Word template and the full research protocol?
→ https://github.com/automation-flow/meeting-prep
