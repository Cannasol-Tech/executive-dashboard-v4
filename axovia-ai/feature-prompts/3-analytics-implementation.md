## Purpose
Implement the analytics components for the Cannasol Technologies Executive Dashboard, connecting to Firebase data sources and creating interactive data visualization cards for the CEO to monitor company performance. **Reference:** Use `axovia-ai/concept-image/analysis-concept-image.png` as a structural guideline for displaying metrics and analysis. Ensure components fit the overall simple, beautiful, modern, sleek design with the dark blue/green color scheme.

## Instructions

1. **Analytics Data Model**
   - Create data models for various analytics metrics
   - Implement serialization/deserialization from Firebase
   - Create trend data structures for time-series visualization
   - Add comparison models for period-over-period analysis

2. **Firebase Analytics Service**
   - Implement service to fetch analytics data from Firebase
   - Create data transformation methods
   - Add caching layer for performance
   - Implement error handling and retry logic
   - Add real-time subscription for live updates

3. **Revenue Metrics Card**
   - Create card displaying current revenue, structurally guided by `analysis-concept-image.png`.
   - Add comparison with previous period.
   - Implement trend visualization with mini chart.
   - Add color coding for positive/negative changes (using theme colors).

4. **Customer Analytics Card**
   - Implement customer count metrics, structurally guided by `analysis-concept-image.png`.
   - Add new vs returning customer breakdown.
   - Create customer acquisition trend chart.
   - Implement filtering by customer segment.

5. **Operations Metrics Card**
   - Create card for operational metrics, structurally guided by `analysis-concept-image.png`.
   - Implement efficiency indicators.
   - Add production timeline visualization.
   - Create capacity utilization chart.

6. **Sales Performance Chart**
   - Implement detailed sales chart by product category
   - Add period comparison capability
   - Create interactive tooltips with detailed data
   - Implement zoom and pan for trend exploration
   - Add export functionality for reports

7. **Regional Performance Map**
   - Create geographical distribution visualization
   - Implement heat map for regional performance
   - Add interactive region selection
   - Create detailed regional breakdown on selection

8. **KPI Summary Card**
   - Implement key performance indicators summary
   - Create goal vs actual visualization
   - Add progress indicators for annual targets
   - Implement trend indicators for each KPI

9. **Analytics Dashboard Provider**
   - Create state management for analytics dashboard
   - Implement data loading and refresh logic
   - Add filtering capability by date range
   - Create view preference persistence
   - Implement dashboard layout customization

10. **Data Export Functionality**
    - Create PDF report generation
    - Implement CSV data export
    - Add email sharing functionality
    - Create scheduled report configuration

11. **Next Steps**
    - Mark `3-analytics-implementation.md` as complete
    - Proceed to `4-authentication-implementation.md` for authentication implementation