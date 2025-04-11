## Task: [Task Name] – <Brief Description>

### ⚠️ MANDATORY POST-TASK CHECKLIST - MUST COMPLETE FOR EVERY TASK ⚠️

**CRITICAL WARNING**: This checklist is MANDATORY and must be completed AFTER implementing ANY task from axovia-ai/planning/implementation-plan.md. A task is NOT COMPLETE until EVERY item on this checklist has been completed. NO EXCEPTIONS.

1. [ ] **Add test coverage**
  a. [ ] Add unit tests covering the new functionality added as thoroughly as possible
     - Dart: Add Flutter tests for all UI components and state management
     - Python: Add PyTest tests for all Cloud Functions
  b. [ ] Add emulation tests where applicable to simulate API responses
     - Create mock responses for Firebase Database queries
     - Simulate email AI agent responses for email management features
     - Create mock data for analytics dashboard
  c. [ ] Add integration testing to ensure new functionality correctly integrates with other components of the system
     - Test Flutter UI to Firebase communication
     - Test Cloud Function triggers and responses
     - Test cross-feature integrations (e.g., email tasks to dashboard)
  d. [ ] Verify Tests are passing and as thorough as possible
     - Run full test suite to ensure no regressions
     - Verify edge cases are covered
  e. [ ] Ensure Unit Test Coverage is 90% of new functionality or higher. If unit test coverage is lower than 90%, restart at step 1 of this section.
     - Verify coverage using appropriate tools for both Flutter and Python code

2. [ ] **Memory Update**
  a. [ ] Read axovia-ai/memory/memory-mgmt.md to get up to date with the memory maintenance guidelines.
  b. [ ] Update axovia-ai/memory/context-memory.md per axovia-ai/memory/memory-mgmt.md guidelines:
     - Add comprehensive implementation details for Cannasol Dashboard feature
     - Document any challenges encountered and solutions implemented
     - Note any architectural decisions made during implementation
     - Document the current state of the feature
  c. [ ] Update axovia-ai/memory/current-task.md to reflect that the task is finished per axovia-ai/memory/memory-mgmt.md:
     - Mark current task as complete
     - Include detailed summary of implementation
     - Document any outstanding issues or future enhancements

3. [ ] **Update/Verify Project Documentation**
  a. [ ] Update axovia-ai/architecture/component-registry.md with new components:
     - Add all new UI components with descriptions and dependencies
     - Document all new Firebase service methods and integrations
     - Update existing component entries if modified
  b. [ ] Update axovia-ai/architecture/codebase-structure.md if file structure changed:
     - Document new directories or files added
     - Update relationships between code modules
  c. [ ] Update axovia-ai/architecture/api-guide.md with any new API endpoints:
     - Document new Cloud Function endpoints with request/response formats
     - Update Firebase Database paths for new features
  d. [ ] Update axovia-ai/architecture/workflow-diagrams.md if feature workflows changed:
     - Add new feature workflow diagrams
     - Document new user interaction flows

4. [ ] **Update/Verify Project Plan**
  a. [ ] Update axovia-ai/planning/implementation-plan.md to mark the implemented task as complete:
     - Change `[ ]` to `[x]` for completed task
     - Update subtasks status if applicable
  b. [ ] Quickly skim axovia-ai/planning/implementation-plan.md to verify nothing has changed and we are still on track and on the same page:
     - Verify dependencies for upcoming tasks
     - Ensure sequence of remaining tasks is logical
  c. [ ] Notify the human that you have updated the implementation plan.

5. [ ] **Object-Oriented Code Quality Review**
  a. [ ] Verify all classes have single responsibilities
     - Each class should have a clear, focused purpose
     - No "god objects" with too many responsibilities
  b. [ ] Confirm all methods are short and focused
     - Methods should ideally be less than 20 lines
     - Each method should do one thing well
  c. [ ] Check appropriate use of inheritance vs. composition
     - Prefer composition over inheritance
     - Use interfaces/abstract classes appropriately
  d. [ ] Verify proper encapsulation
     - Fields private unless needed externally
     - Use getters/setters appropriately

6. [ ] **Version Control**
  a. [ ] Read axovia-ai/versioning/version-control.md to review version control guidelines
  b. [ ] Update axovia-ai/versioning/version-history.md with the new version after the implemented task:
     - Add version number following semantic versioning
     - Document changes implemented in this version
     - Note any breaking changes or API modifications
  c. [ ] Stage files modified in order to implement completed task for commit with 'git add .'
  d. [ ] Create github commit message per the version control rules in axovia-ai/versioning/version-control.md:
     - Use proper commit type (feat, fix, docs, etc.)
     - Include scope of changes in the commit
     - Write clear description of implemented functionality
  e. [ ] Push the new functionality to the remote repository with 'git push'. This should trigger a CI/CD Pipeline run.

7. [ ] **CI/CD Pipeline Verification**
  1. [ ] Check the state of the pipeline, verifying the logs from each stage:
     - Build stage for both Flutter and Cloud Functions
     - Test stage for unit and integration tests
     - Deploy stage for preview deployments
  2. [ ] Ensure there are no errors in any stage of the pipeline:
     - Review error logs if present
     - Identify root causes of any failures
  3. [ ] Fix any errors in the pipeline WITHOUT modifying previously committed code, if applicable.  
     NOTE: Do not proceed past this step until the pipeline has no errors. If you absolutely cannot fix the pipeline errors without modifying previous functionality. STILL, DO NOT DO THIS. Add a request in axovia-ai/communication/requeists-to-human.mdc for a review of the functionality change necessary then only proceed if the human signs off on the change.
  4. [ ] Verify that the deployed preview/staging environment is functioning correctly:
     - Test the new features in the deployed environment
     - Verify integration with other components
     - Check for any environment-specific issues

8. [ ] **Firebase Integration Verification**
  1. [ ] Verify all Firebase interactions work correctly:
     - Authentication flows
     - Firestore data operations
     - Realtime Database subscriptions
     - Cloud Functions triggers
  2. [ ] Check security rules are properly implemented:
     - Verify access control logic
     - Test with different user roles
     - Confirm data validation rules
  3. [ ] Verify error handling for Firebase operations:
     - Connection failures
     - Permission denied scenarios
     - Invalid data scenarios

9. [ ] **Update Agent Memory**
  1. [ ] Read the axovia-ai/memory/memory-mgmt.md guidelines again
  2. [ ] Update the axovia-ai/memory/context-memory.md with implementation highlights:
     - Include information about fixed pipeline errors to avoid replicating in the future
     - Document performance characteristics of implemented features
     - Note any Cannasol-specific considerations discovered
     - Include next steps and dependencies for future features

10. [ ] **Update Release Process**
  1. [ ] Refresh memory on axovia-ai/versioning/version-control.md
  2. [ ] Add, commit and push any pipeline fixes to the remote repository by using the commands: 
     - git add .
     - git commit -m "<commit msg per versioning guidelines>"
     - git push
  3. [ ] Update axovia-ai/CHANGELOG.md with details about the newly implemented feature:
     - Add entry under appropriate version heading
     - Provide concise description of new functionality
     - Document any breaking changes or important notes

11. [ ] **Feature Validation**
  1. [ ] Verify the feature meets all requirements specified in the feature prompt:
     - Check all acceptance criteria are satisfied
     - Ensure all edge cases are handled
     - Verify cross-platform compatibility if applicable
  2. [ ] Test feature in context of the entire application:
     - Verify integration with existing features
     - Test typical user workflows involving the feature
     - Check mobile and desktop experiences if applicable
  3. [ ] Document any outstanding issues or future improvements in axovia-ai/notes/technical-debt.md

## CRITICAL REMINDERS

- NEVER consider a task complete until ALL items on this checklist are completed
- ALWAYS update documentation to reflect the current state of the system
- ENSURE test coverage meets or exceeds the 90% threshold for all new code
- VERIFY integration with existing features works properly
- DOCUMENT all implementation details in the appropriate memory and documentation files
- FOLLOW version control procedures precisely
- NOTIFY the human of task completion and any outstanding issues