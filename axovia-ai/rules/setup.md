# Setup Guide for Cannasol Technologies Executive Dashboard

## Purpose
This document provides comprehensive instructions for setting up the development framework for the Cannasol Technologies Executive Dashboard project, ensuring consistent development practices and preventing code duplication.

## Project Overview
The Cannasol Technologies Executive Dashboard is a Flutter-based application with TypeScript integrations where necessary, backed by Google Cloud Functions (Python) and Firebase services (Firestore and Realtime Database). It provides the CEO with analytical insights, email management, chat capabilities, SEO controls, blog management, and customizable settings.

## Tech Stack
- **Frontend**: Flutter with TypeScript integrations where necessary
- **Backend**: 
  - Google Cloud Functions (Python)
  - Firebase Firestore
  - Firebase Realtime Database
  - Firebase Authentication

## Instructions

1. **Environment Setup**
   ```bash
   # Install Flutter SDK
   flutter --version  # Should be 3.19 or later
   
   # Install Node.js for Firebase tools
   node --version  # Should be 18.x or later
   
   # Install Firebase CLI
   npm install -g firebase-tools
   firebase --version  # Should be 12.x or later
   
   # Install Python 3.10+ for Cloud Functions
   python --version  # Should be 3.10 or later
   ```

2. **Project Repository Setup**
   ```bash
  
   # Set up Flutter project
   flutter create --platforms=web --org=com.cannasol .
   
   # Initialize Firebase project
   firebase login
   firebase init
   # Select Firestore, Realtime Database, Functions, Hosting, and Authentication
   ```

3. **Directory Structure Creation**
   Create the following directory structure:
   ```

flutter-app/
   ├── lib/                        # Flutter source code
   │   ├── config/                 # Configuration files
   │   ├── core/                   # Core application code
   │   ├── features/               # Feature modules
   │   │   ├── analytics/          # Analytics dashboard
   │   │   ├── blog/               # Company blog management
   │   │   ├── chatbot/            # AI assistant chatbot
   │   │   ├── email/              # Email management
   │   │   ├── seo/                # SEO and Google Ads
   │   │   └── settings/           # Application settings
   │   ├── models/                 # Data models
   │   ├── services/               # Service interfaces
   │   ├── shared/                 # Shared components
   │   └── main.dart              # Application entry point
   ├── functions/                  # Cloud Functions
   │   ├── src/                    # Source code
   │   │   ├── analytics/          # Analytics functions
   │   │   ├── blog/               # Blog management functions
   │   │   ├── chatbot/            # Chatbot functions
   │   │   ├── email/              # Email processing functions
   │   │   └── seo/                # SEO functions
   │   ├── index.ts                # Functions entry point
   │   └── requirements.txt        # Python dependencies
   ├── test/                       # Test directory
   │   ├── unit/                   # Unit tests
   │   ├── widget/                 # Widget tests
   │   └── integration/            # Integration tests
   └── web/                        # Web-specific assets
   ```

4. **Firebase Configuration**
   ```bash
   # Generate Firebase configuration
   flutterfire configure --project=cannasol-executive-dashboard
   
   # This will create the firebase_options.dart file in the lib directory
   ```

5. **Dependency Setup**
   Update `pubspec.yaml` with required dependencies:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     # Firebase
     firebase_core:
     firebase_auth:
     cloud_firestore:
     cloud_functions: 
     firebase_database:
     firebase_messaging:
     # State management
     provider: 
     # UI components
     fl_chart: 
     flutter_staggered_grid_view:
     google_fonts: 
     # Utils
     intl: 
     http: 
     url_launcher:
     flutter_dotenv:
   ```

6. **Install Dependencies**
   ```bash
   flutter pub get
   ```

7. **Initialize Git Hooks**
   ```bash
   # Create pre-commit hook
   mkdir -p .git/hooks
   
   cat > .git/hooks/pre-commit << 'EOF'
   #!/bin/sh
   
   # Run Flutter format
   flutter format --set-exit-if-changed lib test
   
   # Run Flutter analyze
   flutter analyze
   
   # Run tests
   flutter test
   EOF
   
   chmod +x .git/hooks/pre-commit
   ```

## Agent Framework Documentation and File Maintenance

Throughout the development process, you will maintain a comprehensive directory structure of documentation files to ensure organization, prevent duplication, and track progress. The agent directory structure is organized as follows:

After completing each task, you must update these files to reflect the current state of the project. The following is a comprehensive list of all documentation files, their purposes, and when the agent should interact with them:

**NOTE: You MUST Create and MAINTAIN every file and directory exactly how it is described below. Do not skip any files or directories.  Maintain updating and interacting with these files as instructed throughout the entire development process.**

1. **axovia-ai/CHANGELOG.md**: Records all notable changes to the project in chronological order.
   - **Purpose**: Maintains a public-facing history of changes, features, and bug fixes.
   - **When to interact**: Update after completing any significant feature, fixing bugs, or when making a release. Use semantic versioning to categorize changes into major, minor, or patch updates.

2. **axovia-ai/CONTRIBUTING.md**: Outlines guidelines for contributing to the project.
   - **Purpose**: Standardizes the contribution process for all developers working on the project.
   - **When to interact**: Consult before making any changes to ensure compliance with project standards. Update when contribution processes change.

3. **axovia-ai/README.md**: Provides a high-level overview of the project.
   - **Purpose**: Serves as the entry point for developers and users to understand the project's purpose, setup, and usage.
   - **When to interact**: Update whenever project scope, setup instructions, or main features change. Should be kept current at all times.

4. **axovia-ai/capabilities/task-certainty.md**: Tracks the agent's confidence in implementing specific tasks.
   - **Purpose**: Helps prioritize work and identify areas needing more research or clarification.
   - **When to interact**: Update before starting any new task to assess confidence level, and after task completion to reflect actual experience.

5. **axovia-ai/ci/build-pipeline.md**: Documents the automated build and testing pipeline.
   - **Purpose**: Ensures consistent build processes across development environments.
   - **When to interact**: Update when changing build tools, adding new build steps, or modifying CI/CD processes.

6. **axovia-ai/ci/deploy-guide.md**: Provides detailed deployment instructions.
   - **Purpose**: Standardizes the deployment process to prevent errors and inconsistencies.
   - **When to interact**: Update after changing deployment targets, procedures, or requirements. Consult before any deployment.

7. **axovia-ai/ci/testing-feedback-loop.md**: Describes the testing workflow and feedback mechanisms.
   - **Purpose**: Establishes procedures for effective testing and incorporating feedback.
   - **When to interact**: Update when changing testing methodologies or tools. Consult when implementing new testing procedures.

8. **axovia-ai/communication/answers-to-agent.md**: Logs human responses to agent questions.
   - **Purpose**: Maintains a record of human guidance and decisions for future reference.
   - **When to interact**: Review before asking questions to avoid repetition. Add entries when recording human responses.

9. **axovia-ai/communication/requeists-to-human.mdc**: Records questions or requests for human input.
   - **Purpose**: Centralized communication channel for agent-human interaction.
   - **When to interact**: Update when needing clarification, credentials, or guidance. Check regularly for human responses.

10. **axovia-ai/config/env-template.md**: Template for required environment variables.
    - **Purpose**: Standardizes environment setup across development environments.
    - **When to interact**: Update when adding new environment variables. Consult when setting up new environments.

11. **axovia-ai/config/secrets-mgmt.md**: Documents best practices for managing secrets.
    - **Purpose**: Ensures secure handling of sensitive information.
    - **When to interact**: Consult before implementing any feature requiring credentials. Update when security practices change.

19. **axovia-ai/rules/resume.md**: Guidelines for resuming work efficiently.
    - **Purpose**: Standardizes the process of resuming work on the project in the Cursor IDE.
    - **When to interact**: Consult at the beginning of each work session after breaks.

20. **axovia-ai/rules/setup.md**: Instructions for initial project setup in Cursor.
    - **Purpose**: Ensures consistent initial setup in the Cursor IDE.
    - **When to interact**: Consult during initial project setup and when onboarding new developers.

21. **axovia-ai/rules/settings.md**: Default IDE settings for the project.
    - **Purpose**: Standardizes IDE behavior for consistent development experience.
    - **When to interact**: Consult when configuring the IDE or when IDE behavior seems inconsistent.

22. **axovia-ai/notes/automation.md**: Documents automated tasks and CI processes.
    - **Purpose**: Catalogs all automated processes in the project.
    - **When to interact**: Update when adding or modifying automation scripts. Consult when troubleshooting automation issues.

23. **axovia-ai/notes/capabilities.md**: Outlines the agent's capabilities and limitations.
    - **Purpose**: Defines the scope of the agent's functionality.
    - **When to interact**: Update when agent capabilities change. Consult when planning new features.

24. **axovia-ai/notes/development-notes.md**: Chronological log of development decisions.
    - **Purpose**: Preserves the reasoning behind technical choices for future reference.
    - **When to interact**: Update after making significant implementation decisions, particularly those deviating from initial plans.

25. **axovia-ai/notes/documentation-reviews.md**: Records documentation review activities.
    - **Purpose**: Tracks the evolution of documentation and ensures its accuracy.
    - **When to interact**: Update after completing documentation reviews. Consult before starting major documentation updates.

26. **axovia-ai/notes/meeting-notes.md**: Records discussions with stakeholders.
    - **Purpose**: Preserves important decisions and discussions from meetings.
    - **When to interact**: Update after meetings with stakeholders. Review before implementing features discussed in meetings.

27. **axovia-ai/notes/technical-debt.md**: Tracks known issues for future resolution.
    - **Purpose**: Ensures technical compromises are documented and eventually addressed.
    - **When to interact**: Update when identifying technical debt. Review when planning refactoring activities.

28. **axovia-ai/how-to/add-a-new-service.md**: Integration guide for new services.
    - **Purpose**: Standardizes the process for integrating new external services.
    - **When to interact**: Consult when adding new service integrations.

29. **axovia-ai/how-to/update-memory.md**: Process for maintaining agent memory.
    - **Purpose**: Guides the management of the agent's persistent memory.
    - **When to interact**: Consult when updating memory structures or when memory issues arise.

30. **axovia-ai/how-to/write-a-plugin.md**: Instructions for extending functionality.
    - **Purpose**: Standardizes plugin development for the system.
    - **When to interact**: Consult when developing new plugins or extending existing ones.

31. **axovia-ai/architecture/api-guide.md**: Details of API endpoints and interfaces.
    - **Purpose**: Documents all API endpoints, request formats, and response structures.
    - **When to interact**: Update when adding or modifying APIs. Consult when implementing features that use APIs.

32. **axovia-ai/architecture/codebase-structure.md**: Documentation of the codebase organization.
    - **Purpose**: Provides a hierarchical representation of the project's structure and relationships.
    - **When to interact**: Update whenever file structure changes. Consult when implementing new features.

33. **axovia-ai/architecture/component-registry.md**: Inventory of all components.
    - **Purpose**: Catalogs all components with their purposes, dependencies, and interfaces.
    - **When to interact**: Update when adding or modifying components. Consult when designing new features.

34. **axovia-ai/architecture/content-management.md**: Documentation of content structure.
    - **Purpose**: Describes how content is organized and managed within the application.
    - **When to interact**: Update when changing content management approaches. Consult when implementing content features.

35. **axovia-ai/architecture/design-system.md**: Visual design specifications.
    - **Purpose**: Documents design standards, typography, colors, and UI patterns.
    - **When to interact**: Consult when implementing UI components. Update when design standards change.

36. **axovia-ai/architecture/user-flows.md**: Documentation of key user journeys.
    - **Purpose**: Maps out typical paths users take through the application.
    - **When to interact**: Consult when implementing features affecting user journeys. Update when adding new flows.

37. **axovia-ai/architecture/workflow-diagrams.md**: Visual representations of system processes.
    - **Purpose**: Illustrates complex processes and interactions between components.
    - **When to interact**: Consult when implementing complex features. Update when processes change.

38. **axovia-ai/feature-prompts/*.md**: Feature specification documents.
    - **Purpose**: Define requirements for each feature in the application.
    - **When to interact**: Consult before implementing each feature. Reference during feature development to ensure all requirements are met.

39. **axovia-ai/logic/goal-hierarchy.md**: Structures for decomposing complex tasks.
    - **Purpose**: Guides the breaking down of large tasks into manageable subtasks.
    - **When to interact**: Consult when planning approaches to complex features.

40. **axovia-ai/logic/interrupt-handling.md**: Procedures for handling unexpected situations.
    - **Purpose**: Defines strategies for handling errors and interruptions.
    - **When to interact**: Consult when implementing error handling. Update with new error patterns.

41. **axovia-ai/logic/task-routing.md**: Logic for categorizing and prioritizing tasks.
    - **Purpose**: Guides the classification and sequencing of implementation tasks.
    - **When to interact**: Consult when determining task priorities and dependencies.

42. **axovia-ai/integrations/llm-provider.md**: Language model provider configuration.
    - **Purpose**: Documents the integration with language model services.
    - **When to interact**: Consult when implementing AI features. Update when changing providers.

43. **axovia-ai/integrations/vector-store.md**: Vector database integration details.
    - **Purpose**: Documents the configuration of vector databases for RAG functionality.
    - **When to interact**: Consult when implementing search or recommendation features. Update when changing providers.

44. **axovia-ai/integrations/zapier.md**: Automation workflow documentation.
    - **Purpose**: Details automation workflows and integrations with Zapier.
    - **When to interact**: Consult when implementing automated processes. Update when workflows change.

45. **axovia-ai/memory/context-memory.md**: Persistent knowledge storage.
    - **Purpose**: Maintains long-term knowledge and system state across sessions.
    - **When to interact**: Update at the end of every session with current status. Review at the start of each new session.

46. **axovia-ai/memory/current-task.md**: Detailed notes on current work.
    - **Purpose**: Tracks real-time details and reasoning for the current task.
    - **When to interact**: Update continuously during task implementation with detailed notes and considerations.

47. **axovia-ai/memory/memory-mgmt.md**: Guidelines for memory management.
    - **Purpose**: Defines procedures for maintaining, pruning, and optimizing agent memory.
    - **When to interact**: Consult when reorganizing memory or resolving memory conflicts.

48. **axovia-ai/monitoring/errors.md**: Documentation of known error patterns.
    - **Purpose**: Catalogs common errors, failure modes, and troubleshooting steps.
    - **When to interact**: Update when encountering new error patterns. Consult when troubleshooting.

49. **axovia-ai/monitoring/logging.md**: Logging system configuration.
    - **Purpose**: Documents the logging system, formats, and retention policies.
    - **When to interact**: Update when changing logging approaches. Consult when setting up logging for new features.

50. **axovia-ai/monitoring/metrics.md**: Performance metrics documentation.
    - **Purpose**: Tracks performance statistics for various parts of the system.
    - **When to interact**: Update when measuring performance. Consult when optimizing performance.

51. **axovia-ai/monitoring/evaluation/benchmarks.md**: Performance benchmark results.
    - **Purpose**: Records standardized performance testing results over time.
    - **When to interact**: Update after running benchmarks. Consult when evaluating performance improvements.

52. **axovia-ai/monitoring/evaluation/human-feedback.md**: Record of human feedback.
    - **Purpose**: Logs user and stakeholder feedback on the system.
    - **When to interact**: Update when receiving feedback. Consult when planning improvements.

53. **axovia-ai/monitoring/evaluation/self-reflection.md**: Agent self-assessment logs.
    - **Purpose**: Contains the agent's assessments of its own performance and reasoning.
    - **When to interact**: Update after completing significant tasks with reflections on approach and effectiveness.

54. **axovia-ai/planning/implementation-plan.md**: Master task list with progress tracking.
    - **Purpose**: Serves as the definitive task tracking system for the project.
    - **When to interact**: Update before starting any task and immediately after completion. Consult at the beginning of each work session.

55. **axovia-ai/plugins/README.md**: Documentation for the plugin architecture.
    - **Purpose**: Guides the development and use of plugins to extend functionality.
    - **When to interact**: Consult when developing plugins. Update when the plugin architecture changes.

56. **axovia-ai/checklists/accessibility.md**: WCAG accessibility requirements.
    - **Purpose**: Ensures the application meets accessibility standards.
    - **When to interact**: Consult when implementing UI components. Verify against when completing UI features.

57. **axovia-ai/checklists/deployment.md**: Deployment procedure checklist.
    - **Purpose**: Standardizes the deployment process to minimize errors.
    - **When to interact**: Consult before and during deployment. Update when deployment processes change.

58. **axovia-ai/checklists/pre-task.md**: Checklist for starting tasks.
    - **Purpose**: Ensures proper preparation before beginning new tasks.
    - **When to interact**: Consult before starting any new implementation task.

59. **axovia-ai/checklists/post-task.md**: Checklist for completing tasks.
    - **Purpose**: Ensures thorough completion and documentation of tasks.
    - **When to interact**: Consult after completing any implementation task.

60. **axovia-ai/testing/test-coverage.md**: Record of test coverage by feature.
    - **Purpose**: Tracks the completeness of testing across the application.
    - **When to interact**: Update after implementing tests. Consult when planning testing strategies.

61. **axovia-ai/testing/testing-plan.md**: Strategy for testing future features.
    - **Purpose**: Guides the approach to testing upcoming features.
    - **When to interact**: Update when planning new features. Consult before implementing tests.

62. **axovia-ai/versioning/version-control.md**: Git workflow and commit conventions.
    - **Purpose**: Standardizes version control practices across the project.
    - **When to interact**: Consult before making commits or creating branches. Update when changing Git workflows.

63. **axovia-ai/versioning/version-history.md**: Detailed changelog of version releases.
    - **Purpose**: Documents the evolution of the application through releases.
    - **When to interact**: Update when creating new releases. Consult when planning version increments.

## Project Configuration Files and Services
Create the following essential files:

1. **Theme Configuration**
   - Contains theme settings with dark blue and dark green as primary/secondary colors
   - Create in `lib/config/theme.dart`

2. **Firebase Service**
   - Centralized Firebase access
   - Create in `lib/services/firebase_service.dart`

3. **Authentication Service**
   - Google Authentication implementation
   - Create in `lib/services/auth_service.dart`

4. **Main Application Entry**
   - Application initialization with Firebase
   - Update `lib/main.dart`

5. **Dashboard Layout**
   - Main dashboard grid layout
   - Create in `lib/features/analytics/presentation/dashboard_screen.dart`

## Critical Rules for AI Coding Agent

1. **NEVER DUPLICATE CODE**: Always check existing components in the component registry before implementing new functionality. Extract shared functionality into reusable components.
2. **USE OBJECT-ORIENTED PRINCIPLES**: Create small, focused classes with single responsibilities. Prefer composition over inheritance. Keep methods short and focused on a single task.
3. **FOLLOW THE FEATURE-FIRST STRUCTURE**: Organize code by feature modules rather than technical layers.
4. **MAINTAIN SEPARATION OF CONCERNS**: 
   - Presentation: UI components and screens
   - Business Logic: Services and providers
   - Data: Models and repositories
5. **ASK THE HUMAN IMMEDIATELY IF CONFUSED**: If requirements are ambiguous or if technical decisions are unclear, ALWAYS ask for clarification before proceeding.
6. **VERIFY BEFORE IMPLEMENTATION**: Always check the implementation plan and component registry before starting any task to ensure no duplication occurs.
7. **UPDATE DOCUMENTATION AFTER IMPLEMENTATION**: Always update relevant documentation files after completing a task.
8. **FOLLOW ESTABLISHED NAMING CONVENTIONS**:
   - Classes: PascalCase (e.g., DashboardScreen)
   - Variables/methods: camelCase (e.g., userProfile)
   - Constants: UPPER_SNAKE_CASE (e.g., API_BASE_URL)
   - Files: snake_case.dart (e.g., dashboard_screen.dart)


## Next Steps

1. Complete the `pre-task.md` checklist before starting any implementation
2. Refer to the `implementation-plan.md` to identify the first task
3. Complete each task according to the plan, following the established guidelines
4. Use the `post-task.md` checklist after completing each task

Remember: The framework is designed to maintain project integrity through rigorous verification procedures. Follow the checklists and documentation to ensure consistent development practices.