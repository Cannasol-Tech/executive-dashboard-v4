# resume.md

```markdown
# Resume Procedures

## Purpose
This document outlines the procedures for resuming work after interruption, session changes, or system restart to ensure continuity and prevent duplication or inconsistency in the Cannasol Technologies Executive Dashboard project.

## Session Resumption Procedures

### Context Retrieval
1. Load essential memory files:
   - `axovia-ai/memory/context-memory.md`
   - `axovia-ai/memory/current-task.md`
   - `axovia-ai/planning/implementation-plan.md`

2. Verify project structure:
   - Check `axovia-ai/architecture/codebase-structure.md`
   - Review `axovia-ai/architecture/component-registry.md`

3. Check communication status:
   - Review `axovia-ai/communication/requeists-to-human.mdc` for pending requests
   - Check `axovia-ai/communication/answers-to-agent.md` for recent responses

### State Verification
1. Confirm current task:
   - Verify the current task in `axovia-ai/memory/current-task.md`
   - Check task status in `axovia-ai/planning/implementation-plan.md`
   - Ensure the task hasn't been completed or modified

2. Review work in progress:
   - Check for uncommitted changes
   - Review recent code changes for context
   - Verify any partial implementations

3. Validate environment:
   - Confirm access to required Firebase credentials
   - Verify development environment is properly set up
   - Check for any system changes since last session

### Session Continuation
1. Update status:
   - Add session resumption note to `axovia-ai/memory/context-memory.md`
   - Update `axovia-ai/memory/current-task.md` with current status

2. Re-establish context:
   - Summarize current understanding of the task
   - Note any gaps or uncertainties
   - Identify immediate next steps

3. Continue with task:
   - If in the middle of a task, continue from current position
   - If starting a new task, complete pre-task checklist
   - If finishing a task, complete post-task checklist

## Feature-Specific Context Restoration

### Dashboard Features
1. **Analytics Dashboard**
   - Review current implementation of analytics cards
   - Check which data sources have been integrated
   - Verify Firebase queries and data flow

2. **Email Management**
   - Verify connection status to email AI agent
   - Check implementation status of approval/editing functionality
   - Review task list generation and management components

3. **Chatbot Interface**
   - Verify REST endpoint configuration (or dummy endpoint)
   - Check UI component implementation status
   - Review message flow and conversation state management

4. **SEO Management**
   - Check implementation of SEO data visualization
   - Verify configuration interface for website parameters
   - Review Google Ads integration status

5. **Blog Management**
   - Verify Firebase Realtime Database connection for content ideas
   - Check implementation of blog post scheduling interface
   - Review content idea submission functionality

6. **Settings**
   - Check theme customization implementation
   - Verify color profile saving functionality
   - Review user preference persistence

## Conflict Resolution

If conflicting or inconsistent states are detected:

1. Document discrepancies:
   - Note specific inconsistencies in `axovia-ai/memory/context-memory.md`
   - Document in `axovia-ai/communication/requeists-to-human.mdc`

2. Propose resolution:
   - Suggest specific resolution approach
   - Outline options with pros and cons
   - Request human guidance if needed

3. After resolution:
   - Update memory with resolution decision
   - Synchronize all relevant documentation
   - Confirm consistent state before proceeding

## Code Review on Resume

Before continuing implementation:

1. Review any recently implemented code:
   - Check for adherence to object-oriented principles
   - Verify modularity and function size/scope
   - Ensure proper separation of concerns

2. Verify component integration:
   - Check interfaces between components
   - Verify state management implementation
   - Ensure data flow is properly established

3. Test functionality:
   - Run unit tests for recently implemented features
   - Verify widget rendering where applicable
   - Check Firebase integration for completed features

## Critical Rules

- NEVER assume the task state without verification
- ALWAYS check for changes before continuing work
- DOCUMENT session resumption in memory files
- VERIFY environment before continuing development
- COMMUNICATE any uncertainties to the human
- UPDATE memory after re-establishing context