# Contributing to Cannasol Technologies Executive Dashboard

Thank you for considering contributing to the Cannasol Technologies Executive Dashboard project. This document outlines the process for contributing to this project and helps ensure consistent quality across the codebase.

## Development Workflow

1. **Select a Task**: Choose an unassigned task from `axovia-ai/planning/implementation-plan.md`
2. **Pre-Task Checklist**: Complete the checklist in `axovia-ai/checklists/pre-task.md`
3. **Implementation**: Follow the project's coding standards and architecture
4. **Post-Task Checklist**: Complete the checklist in `axovia-ai/checklists/post-task.md`
5. **Update Documentation**: Update relevant documentation files
6. **Submit Pull Request**: Create a pull request with your changes

## Coding Standards

### Dart/Flutter

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Write comments for complex logic
- Create small, focused classes with single responsibility
- Write tests for all new functionality
- Keep methods short and focused

### Code Organization

- Organize code by feature, not by type
- Place related files in the same directory
- Keep feature modules independent when possible
- Follow the established project structure

## Git Workflow

- Create a new branch for each task
- Use the following branch naming convention: `feature/task-name` or `fix/issue-description`
- Make small, focused commits with descriptive messages
- Reference task numbers in commit messages
- Keep pull requests focused on a single task

## Pull Request Process

1. Ensure your code follows the project's coding standards
2. Update relevant documentation
3. Include tests for new functionality
4. Make sure all tests pass
5. Submit the pull request with a clear description
6. Address any review comments promptly

## Component Development

- Check `axovia-ai/architecture/component-registry.md` before creating new components
- Register new reusable components in the component registry
- Follow the established component patterns
- Use composition over inheritance
- Design components for reusability

## Communication

- Document any questions in `axovia-ai/communication/requests-to-human.md`
- Record major decisions in `axovia-ai/notes/development-notes.md`
- Update `axovia-ai/memory/context-memory.md` with implementation progress
- Document any technical debt in `axovia-ai/notes/technical-debt.md`

## Getting Help

If you need help with any aspect of the contribution process, please contact the project maintainers.
