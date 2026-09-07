# Plan

Create a structured implementation plan for a task and save it as a trackable file.

## Input

The user describes what they want to build or fix. Can be a short sentence or detailed brief.

## Steps

### 1. Understand the scope
Read relevant existing files to understand current state:
- `CURRENT_STATUS.md` — what's in progress now
- `CLAUDE.md` — project architecture and key identifiers
- Any tracking files mentioned in CURRENT_STATUS.md

### 2. Research
If the task involves existing components:
- Read relevant source files or configurations
- Run validation if applicable
- Understand what exists before planning changes

For n8n projects specifically:
- Fetch the workflow with the workflow-reader agent or `n8n_get_workflow` (mode=structure)
- Run workflow validation if relevant

### 3. Create the plan
Write a plan file to `docs/plans/PLAN-<short-name>.md` with this structure:

```markdown
# Plan: <Title>

**Created:** <date>
**Status:** ACTIVE
**Target components:** <list affected components — workflows, features, pages, etc.>
**Depends on:** <any plans that must complete first, or "none">

## Goal
<1-2 sentences: what this achieves>

## Phases

### Phase 1: <Name>
- [ ] **1.1** <Task description>
  - Where: <component/file/workflow>
  - What: <specific change>

### Phase 2: <Name>
- [ ] **2.1** ...

## Testing
- [ ] **T1** <Test description>

## Risks
- <what could go wrong and how to handle it>

## Handoff Notes
<context the next agent needs to continue this work>
```

### 4. Update CURRENT_STATUS.md
Add the new plan to the active work section.

### 5. Present the plan
Show the user a summary and ask for approval before proceeding.

## Rules
- Each task should be small enough to complete and verify independently
- Each phase should be testable before moving to the next
- Always identify which components are affected
- Never start implementing during the plan command — just plan
