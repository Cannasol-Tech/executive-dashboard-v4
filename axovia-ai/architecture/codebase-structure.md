# codebase-structure.md — Axovia AI Coding Framework Project Structure

## Purpose

This document provides an **extensive definition** of every major directory and file within the Axovia AI Development Framework, ensuring consistency, maintainability, and clarity. It also describes how the `axovia-ai/` framework structure operates as a foundation for planning, memory, and AI assistant interactions.

---

## High-Level Overview

```
/
├── axovia-ai/            # Documentation, axovia-ai/ Framework, and Project Planning
│   ├── checklists/         # Mandatory pre-task & post-task verification
│   │   ├── pre-task.md       # Verification steps to complete before starting a task
│   │   ├── post-task.md      # Verification steps to complete after finishing a task
|   ├── capabilities/`**: Documents the axovia-ai/'s perceived capabilities and limitations. 
│   |    └── task-confidence.md  # Displays the axovia-ai/'s tasks with a confidence level
│   ├── memory/             # Memory context, current task, and management rules
│   │   ├── memory-context.md # Summaries of architectural state and decisions
│   │   ├── current-task.md   # Tracks the single active task in progress
│   │   └── memory-mgmt.md    # Guidelines for continuity and pruning stale data
│   ├── communication/      # Requests-to-human, answers-to-axovia-ai/ logs
│   │   ├── requests-to-human.md  # axovia-ai/ queries requiring human feedback
│   │   └── answers-to-axovia-ai/.md   # Human-provided solutions or decisions
│   ├── config/             # Environment templates, secrets management docs
│   │   ├── env-template.md      # Template specifying required environment variables
│   │   └── secrets-mgmt.md      # Best practices for API keys and sensitive data
│   ├── credentials/        # Securely stored API or platform credentials references
│   ├── rules/              # Custom rule sets (setup, resume, etc.)
│   │   ├── setup.md        # Initial environment configuration rules
│   │   └── resume.md       # Rules for resuming work on tasks
│   ├── notes/              # Development notes, meeting notes, technical debt
│   │   ├── development-notes.md  # Running log of day-to-day dev decisions
│   │   ├── meeting-notes.md      # Summaries of stakeholder discussions
│   │   └── technical-debt.md     # Lists known issues for future resolution
│   ├── architecture/       # System diagrams, code structure, design guidelines
|   |   ├── project-structure.md            # Diagram of the working projects code structure 
│   │   ├── axovia-framework-structure.md   # This document - codebase organization
│   │   ├── component-registry.md           # Registry of reusable components
│   │   ├── design-system.md                # Design principles and guidelines
│   │   ├── api-guide.md                    # API documentation and usage
│   │   └── workflow-diagrams.md            # Visual representations of key workflows
│   ├── monitoring/         # Errors, metrics, evaluation, logs
│   │   ├── errors.md         # Catalog of known error states and solutions
│   │   └── metrics.md        # Performance or usage statistics tracking
│   ├── plugins/            # Any plugin architecture docs
│   ├── research/           # Research findings on tools, APIs, or approaches
│   ├── testing/            # Testing plan, coverage tracking, e2e test docs
│   │   ├── test-coverage.md   # Documentation of test coverage requirements
│   │   └── testing-plan.md    # Strategic approach to testing the system
│   ├── versioning/         # Version-control guidelines, version history
│   │   ├── version-control.md   # Guidelines for version control procedures
│   │   └── version-history.md   # Record of version changes and updates
│   ├── planning/           # Master implementation plan, major scheduling
│   │   └── implementation-plan.md  # Comprehensive list of tasks with statuses
│   ├── integrations/       # External service integration docs
│   │   ├── zapier.md            # Documentation for Zapier integration
│   │   └── langchain_integration.md  # Documentation for LangChain integration
│   └── ci/                 # CI/CD scripts, pipeline feedback logic
│       └── pipeline-feedback-check.sh  # Script to block progress if tests fail
│   └── schema/                 # structure documents (i.e. database schema)
│       ├── firestore-database.md   #  Well documented database schema, managed by agent
│       └── realtime-database.md   #  Well documented database schema, managed by agent
├── testing/                # Project-wide testing resources
│   ├── testing-plan.md       # Overall testing strategy for the project
│   └── testing-coverage.md   # Documentation of test coverage across the project
└── ...
```

---

## File Descriptions

### Root Level Files

#### CHANGELOG.md

- **Purpose**: Documents version history and changes to the project
- **Content**: Follows the Keep a Changelog format with sections for Added, Changed, Fixed, and Removed
- **Usage**: Updated with each release to track project evolution

#### CONTRIBUTING.md

- **Purpose**: Guidelines for contributing to the project
- **Content**: Development setup, workflow processes, coding standards, and PR guidelines
- **Usage**: Reference for new contributors and team members

### Architecture Directory

#### api-guide.md

- **Purpose**: Documents APIs and integration points
- **Content**: API endpoints, parameters, authentication, response formats, and example usage
- **Usage**: Reference for developers implementing integrations

#### codebase-structure.md

- **Purpose**: Explains the project's file organization
- **Content**: Directory structure, file purposes, and organization principles
- **Usage**: Orientation for new developers and maintaining consistent organization

#### component-registry.md

- **Purpose**: Catalogs all system components
- **Content**: Component names, responsibilities, dependencies, and usage examples
- **Usage**: Reference to understand component relationships and responsibilities

#### design-system.md

- **Purpose**: Defines UI/UX standards
- **Content**: Color schemes, typography, spacing, components, and accessibility guidelines
- **Usage**: Ensures consistent design implementation across the application

#### user-flows.md

- **Purpose**: Documents user journeys
- **Content**: Step-by-step user paths through key features with annotations
- **Usage**: Understanding user experience and feature relationships

#### workflow-diagrams.md

- **Purpose**: Visualizes system processes
- **Content**: Flowcharts, sequence diagrams, and data flow diagrams
- **Usage**: Understanding complex interactions between system components

### Checklist Directory

#### post-task.md

- **Purpose**: Verification steps after task completion
- **Content**: Checklist for documentation, testing, and code quality
- **Usage**: Ensure consistent task closure and quality control

#### pre-task.md

- **Purpose**: Preparation steps before starting a task
- **Content**: Checklist for understanding requirements, checking dependencies, and planning
- **Usage**: Ensure proper preparation and prevent rework

### Rules Directory

#### resume.md

- **Purpose**: Guidelines for resuming work after breaks
- **Content**: Steps to reload context and re-establish understanding of state
- **Usage**: Maintain continuity between work sessions

#### resume.md

- **Purpose**: Template for context resumption
- **Content**: Markdown template for documenting session state
- **Usage**: Standardize context documentation

#### settings.md

- **Purpose**: axovia-ai/ behavior configuration
- **Content**: Rules, preferences, and constraints for axovia-ai/ operation
- **Usage**: Standardize axovia-ai/ behavior across sessions

#### setup.md

- **Purpose**: Project setup instructions
- **Content**: Environment setup, tool installation, and configuration steps
- **Usage**: Onboarding new developers

#### start-task.md

- **Purpose**: Task initialization guidelines
- **Content**: Steps for properly beginning new tasks
- **Usage**: Establish consistent task handling

### Memory Directory

#### context-memory.md

- **Purpose**: Stores current project state
- **Content**: Implementation details, decisions, and current progress
- **Usage**: Maintain continuity across development sessions

#### current-task.md

- **Purpose**: Tracks active tasks
- **Content**: Task details, status, progress, and blockers
- **Usage**: Focus point for current development efforts

#### memory-mgmt.md

- **Purpose**: Memory management guidelines
- **Content**: Principles for managing axovia-ai/ memory
- **Usage**: Optimize axovia-ai/ performance and context management

### Planning Directory

#### implementation-plan.md

- **Purpose**: Project roadmap and task tracking
- **Content**: Tasks, statuses, dependencies, and implementation details
- **Usage**: Guide development sequence and monitor progress

## Other Key Directories

### feature-prompts/

- **Purpose**: Feature specifications
- **Content**: Detailed requirements, user stories, and acceptance criteria
- **Usage**: Define expected functionality for implementation

### research/

- **Purpose**: Research findings
- **Content**: Analysis of technologies, approaches, and alternatives
- **Usage**: Document research to inform development decisions

### integrations/

- **Purpose**: External service integration documentation
- **Content**: Integration details, authentication methods, and usage examples
- **Usage**: Guide for implementing external service connections

### logic/

- **Purpose**: axovia-ai/ logic patterns
- **Content**: Algorithms, decision trees, and pattern implementations
- **Usage**: Reference for implementing consistent axovia-ai/ behaviors

## Development Workflow

The development workflow follows these steps:

1. Review the implementation plan to identify the next task
2. Complete the pre-task checklist to ensure proper preparation
3. Implement the task following the project's coding standards
4. Update the context memory with new implementation details
5. Complete the post-task checklist to verify proper completion
6. Update the implementation plan with the task status
7. Commit changes following the project's versioning guidelines

## Conclusion

This document provides a comprehensive reference for the Axovia Flow project structure. Maintaining this organization is crucial for scalability, maintainability, and collaboration. All team members should follow these guidelines when adding new files or modifying existing ones.
