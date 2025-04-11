# Pre-Task Checklist

## Purpose
This checklist must be completed before beginning any implementation task for the Cannasol Technologies Executive Dashboard project to ensure proper preparation, prevent duplication, and validate task readiness.

## Task Details
- [ ] **Task Name:** [Name of the task from implementation-plan.md]
- [ ] **Feature Prompt:** [Corresponding feature prompt file]
- [ ] **Priority:** [High/Medium/Low]

## Communication Protocol

If ANY item in this checklist cannot be completed or ANY confusion arises:

1. Document specific issue in `axovia-ai/notes/development-notes.md` with:
   - Detailed description of the issue
   - Related components or files
   - Potential impact on implementation
   - Suggested clarification or resolution approaches

2. Format question to human as:
    [PRE-TASK VALIDATION ISSUE]
        - Context: [Brief context about the task]
        - Issue: [Specific issue preventing checklist completion]
        - Impact: [How this affects implementation]
        - Question: [Specific, actionable question]
        - Options: [If applicable, list potential approaches]

3. Update `axovia-ai/memory/current-task.md` to reflect blocked status

4. Move on to other next tasks in implementation-plan

5. Document human response (when received) in `axovia-ai/communication/answers-to-agent.md`

## Preparation Checklist
- **Important Note:** This must be filled out accurately before EVERY SINGLE TASK from `implementation-plan.md` is filled out. 

### Memory Loading
- [ ] Review axovia-ai/memory/context-memory.md to understand current project state
- [ ] Review axovia-ai/memory/current-task.md to confirm this is the correct next task
- [ ] Check axovia-ai/planning/implementation-plan.md to verify task is next in sequence

### Architecture Validation
- [ ] Review axovia-ai/architecture/component-registry.md to understand existing components
- [ ] Review axovia-ai/architecture/codebase-structure.md to understand file organization
- [ ] Check for similar components that might already exist or need extension

### Duplication Prevention for Cannasol Dashboard
- [ ] Search codebase for similar implementations of dashboard components/features
- [ ] Verify the task hasn't been partially implemented already
- [ ] Check if feature-specific directories already exist for the given task
- [ ] Identify opportunities for code reuse, especially for:
- [ ] UI components (cards, dialogs, buttons)
- [ ] Firebase service methods
- [ ] Data models
- [ ] State management patterns
- [ ] All potential duplication has been ruled out

### Dependency Check
- [ ] Verify all required Flutter packages are available
- [ ] Confirm Firebase services are configured for the feature
- [ ] Check if dependent features are complete (per feature dependencies)
- [ ] Verify any required Cloud Functions are implemented
- [ ] Check if necessary mockups or designs are available for UI implementation

### Implementation Planning
- [ ] Identify appropriate component patterns for implementation:
- [ ] For UI components: Determine widget hierarchy and layout approach
- [ ] For services: Determine service interface and implementation structure
- [ ] For state management: Select appropriate state pattern (Provider, streams, etc.)
- [ ] Outline component interfaces and responsibilities
- [ ] Create brief implementation approach
- [ ] Identify potential challenges or uncertainties

### Technical Validation
- [ ] Verify Flutter environment is properly set up
- [ ] Confirm access to required Firebase project credentials
- [ ] Check for any Firebase service limitations or requirements
- [ ] Verify connection to required external services (if applicable)
- [ ] Confirm all required development tools are installed (Firebase CLI, Flutter SDK)

## Feature-Specific Checks

### For Analytics Dashboard Features
- [ ] Verify data source for analytics information
- [ ] Check existing card components for reuse
- [ ] Confirm chart/graph requirements
- [ ] Verify Firestore data structure for analytics

### For Email Management Features
- [ ] Verify Firebase DB path for AI-generated email content
- [ ] Check existing approval interface components
- [ ] Confirm task list data model requirements
- [ ] Verify Firestore/RTDB structure for email data

### For Chatbot Interface Features
- [ ] Verify REST endpoint configuration (or dummy endpoint details)
- [ ] Check existing chat UI components
- [ ] Confirm message flow requirements
- [ ] Verify Firebase structure for chat persistence (if applicable)

### For SEO Management Features
- [ ] Verify data source for SEO information
- [ ] Check existing configuration interface components
- [ ] Confirm Google Ads integration requirements
- [ ] Verify Firebase structure for SEO configuration

### For Blog Management Features
- [ ] Verify Firebase RTDB path for content ideas
- [ ] Check existing blog management components
- [ ] Confirm post scheduling requirements
- [ ] Verify Firebase structure for blog data

### For Settings Features
- [ ] Verify theme customization requirements
- [ ] Check existing theme components
- [ ] Confirm color profile saving mechanism
- [ ] Verify Firebase structure for user preferences

## Communication Check
- [ ] Review axovia-ai/communication/requeists-to-human.mdc for any pending answers
- [ ] Document any new questions or uncertainties before starting
- [ ] Update axovia-ai/memory/current-task.md with pre-task status

## Final Verification
- [ ] Confirm clear understanding of feature requirements from prompt file
- [ ] Verify implementation approach aligns with project architecture
- [ ] Confirm no technical blockers preventing implementation
- [ ] Update memory with pre-task completion status