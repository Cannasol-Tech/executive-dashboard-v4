# Requests to Human

This document tracks questions and clarification requests from the agent to human collaborators. Each request should follow the structured format below.

## Active Requests

## Addressed Requests

### [REQ-001] Firestore Database Structure Documentation
- **Context**: Need to have well documented database structures.
- **Question**: Can you create a file in the axovia-ai/schema/ directory with a database structure of our firebase database? 
- **Impact**: Keeps ups aligned on our database format
- **Status**: RESOLVED
- **Resolution**: Created comprehensive Firebase database structure documentation in `/axovia-ai/schema/firebase-database-structure.md` covering Firestore collections, Firebase Storage, and Realtime Database structures.

### [REQ-002] Implementation-plan restructure
- **Context**: Need document generator now
- **Question**: Can you restructure our plan to put the document generator feature in front of the chatbot implementation?
                    - This will require changing both the #file:planning/implementation-plan.md file and the #feature-prompts directory
- **Impact**: Fixes our prioritization
- **Status**: RESOLVED
- **Resolution**: Reordered implementation plan to prioritize Document Viewer & Downloader (now item #7) ahead of Chatbot Interface (now item #8). Renamed corresponding feature prompt files to match the new order.

### [REQ-000] Template Example
- **Context**: Example request template.
- **Question**: Should we use X or Y technology?
- **Options**: 
  1. Option X with pros and cons
  2. Option Y with pros and cons
- **Impact**: How this decision affects the project.
- **Status**: RESOLVED
- **Resolution**: Option X selected because of [specific reasons].