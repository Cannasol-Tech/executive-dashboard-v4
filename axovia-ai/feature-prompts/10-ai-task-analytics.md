## Purpose
Implement the AI Task Analytics feature for the Cannasol Technologies Executive Dashboard. This feature will display metrics related to the generation, approval, rejection, and completion of tasks suggested or performed by the backend AI agents, categorized by task type. **Reference:** Use `axovia-ai/concept-image/analysis-concept-image.png` as a structural guideline for displaying these metrics. Ensure components fit the overall simple, beautiful, modern, sleek design with the dark blue/green color scheme.

## Instructions

1.  **Task Log Data Model**
    *   Ensure backend systems log relevant task data to a designated database collection (e.g., `ai_task_logs` in Firestore).
    *   Required fields: Task ID, Task Description, Task Category/Type (e.g., 'email_response', 'document_generation', 'label_printing'), Status (e.g., 'pending_approval', 'approved', 'rejected', 'in_progress', 'completed', 'failed'), Timestamp Created, Timestamp Actioned (Approved/Rejected), Timestamp Completed.
    *   Confirm data structure with backend team.

2.  **Task Analytics Service**
    *   Create a service to query the `ai_task_logs` collection.
    *   Implement functions to calculate key metrics:
        *   Total tasks presented for approval (status != 'pending_approval')
        *   Number of approved tasks
        *   Number of rejected tasks
        *   Number of completed tasks (status == 'completed')
        *   Acceptance Rate = (Approved Tasks / Total Tasks Presented)
        *   Rejection Rate = (Rejected Tasks / Total Tasks Presented)
    *   Implement filtering capabilities (e.g., by date range, by task category).
    *   Handle potential aggregation/calculation efficiently, possibly leveraging database queries or cloud functions if data volume is large.

3.  **Analytics Display Interface**
    *   Design a dedicated tab or section within the dashboard for AI Task Analytics, structurally guided by `analysis-concept-image.png`.
    *   Display overall key metrics clearly (e.g., overall acceptance rate, total completed tasks this month).

4.  **Categorized Metrics View**
    *   Implement a view (e.g., table, grouped bar chart) to show the key metrics broken down by Task Category, using `analysis-concept-image.png` for structural inspiration.
    *   Allow users to easily compare performance across different task types.

5.  **Trend Visualization (Optional)**
    *   Consider adding charts to visualize trends over time (e.g., acceptance rate per week/month, number of completed tasks per category over time).

6.  **Data Filtering Controls**
    *   Provide UI controls for users to filter the analytics data (e.g., date range picker, category selector).

7.  **State Management**
    *   Integrate task analytics data fetching, calculation, and display state into the application's state management solution.
    *   Handle loading and error states gracefully.

8.  **Testing**
    *   Test calculations thoroughly with sample task log data covering various statuses and categories.
    *   Verify filtering logic and date range queries.

9.  **Next Steps**
    *   Mark `10-ai-task-analytics.md` as complete upon implementation.
    *   Proceed to `11-seo-management.md` for SEO Management implementation. 