# Component Registry

This document catalogs all reusable components within the Cannasol Technologies Executive Dashboard, ensuring consistent implementation and preventing duplication.

## UI Components

### Navigation Components

| Component | Description | Location | Dependencies | Status |
|-----------|-------------|----------|--------------|--------|
| SideNavigationPanel | Main navigation sidebar with animated transitions | `lib/shared/widgets/navigation/side_navigation_panel.dart` | `Provider` | Implemented |
| NavItem | Individual navigation item with hover effects | `lib/shared/widgets/navigation/nav_item.dart` | None | Implemented |

### Dashboard Components

| Component | Description | Location | Dependencies | Status |
|-----------|-------------|----------|--------------|--------|
| DashboardCard | Base card component for dashboard items | `lib/shared/widgets/dashboard/dashboard_card.dart` | None | Implemented |
| RevenueMetricsCard | Card displaying revenue metrics | `lib/features/analytics/widgets/revenue_metrics_card.dart` | `DashboardCard`, `DashboardSummary` | Implemented |
| CustomerAnalyticsCard | Card showing customer analytics | `lib/features/analytics/widgets/customer_analytics_card.dart` | `DashboardCard`, `DashboardSummary` | Implemented |
| OperationsMetricsCard | Card displaying operations metrics | `lib/features/analytics/widgets/operations_metrics_card.dart` | `DashboardCard`, `DashboardSummary` | Implemented |
| SalesPerformanceChart | Visual chart for sales data | `lib/features/analytics/widgets/sales_performance_chart.dart` | `fl_chart` | In progress |

### Form Components

| Component | Description | Location | Dependencies | Status |
|-----------|-------------|----------|--------------|--------|
| PrimaryButton | Main action button with animation | `lib/shared/widgets/common/primary_button.dart` | None | Implemented |

## Service Components

### Firebase Services

| Service | Description | Location | Dependencies | Status |
|---------|-------------|----------|--------------|--------|
| FirestoreService | Core service for Firestore access | `lib/services/firestore_service.dart` | `cloud_firestore` | Implemented |
| AuthService | Authentication service for Google login | `lib/services/auth_service.dart` | `firebase_auth` | Planned |

### State Management

| Provider | Description | Location | Dependencies | Status |
|----------|-------------|----------|--------------|--------|
| AnalysisDataProvider | Provides analysis data to UI | `lib/features/analytics/providers/analysis_data_provider.dart` | `Provider`, `FirestoreService` | Implemented |
| DashboardSummaryProvider | Provides dashboard summary data | `lib/features/analytics/providers/dashboard_summary_provider.dart` | `Provider`, `FirestoreService` | Implemented |

## Data Models

| Model | Description | Location | Dependencies | Status |
|-------|-------------|----------|--------------|--------|
| AnalysisData | Represents detailed analytics data | `lib/features/analytics/models/analysis_data.dart` | None | Implemented |
| DashboardSummary | Represents summary metrics for dashboard | `lib/features/analytics/models/dashboard_summary.dart` | None | Implemented |

## Notes

- When creating new components, check this registry first to avoid duplication
- Follow the naming conventions and organization patterns of existing components
- Update this registry when implementing new reusable components
- Prefer composition over inheritance when extending functionality
