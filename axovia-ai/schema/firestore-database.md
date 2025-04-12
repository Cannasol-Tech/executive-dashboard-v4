# Cannasol Executive Dashboard - Firebase Database Structure

This document outlines the structure of the Firebase databases (Firestore, Realtime Database, and Storage) used in the Cannasol Technologies Executive Dashboard.

## Database URLs

- **Firestore Database:** https://firestore.googleapis.com/v1/projects/cannasol-exec-dashboard/databases/(default)
- **Realtime Database:** https://cannasol-exec-dashboard-rtdb.firebaseio.com/
- **Firebase Storage:** https://storage.googleapis.com/cannasol-exec-dashboard.appspot.com/
- **Firebase Console:** https://console.firebase.google.com/project/cannasol-exec-dashboard/

## Firestore Database

### Collection: `users`

Stores user account information and preferences.

```
users/
  ├── {userId}/
  │     ├── displayName: string
  │     ├── email: string
  │     ├── photoURL: string
  │     ├── role: string (admin | user)
  │     ├── createdAt: timestamp
  │     ├── lastLoginAt: timestamp
  │     └── preferences: {
  │           ├── theme: string (light | dark | system)
  │           ├── colorProfile: string 
  │           ├── enableGlowEffects: boolean
  │           └── dashboardLayout: object
  │     }
```

### Collection: `dashboard`

Stores data for the main dashboard display.

```
dashboard/
  ├── summary/
  │     ├── revenue: {
  │     │     ├── current: number
  │     │     ├── previous: number
  │     │     ├── trend: number (percentage change)
  │     │     └── forecastNextMonth: number
  │     │ }
  │     ├── customers: {
  │     │     ├── total: number
  │     │     ├── active: number
  │     │     ├── new: number
  │     │     └── churnRate: number
  │     │ }
  │     ├── operations: {
  │     │     ├── ordersProcessed: number
  │     │     ├── averageFulfillmentTime: number
  │     │     ├── returnRate: number
  │     │     └── inventoryStatus: string
  │     │ }
  │     └── lastUpdated: timestamp
  │
  ├── analysis/
  │     ├── salesPerformance: [
  │     │     {
  │     │         month: string,
  │     │         value: number
  │     │     }
  │     │ ]
  │     ├── regionalPerformance: [
  │     │     {
  │     │         region: string,
  │     │         revenue: number,
  │     │         customers: number
  │     │     }
  │     │ ]
  │     ├── kpiSummary: {
  │     │     ├── customerAcquisitionCost: number
  │     │     ├── customerLifetimeValue: number
  │     │     ├── conversionRate: number
  │     │     └── marketingROI: number
  │     │ }
  │     └── lastUpdated: timestamp
```

### Collection: `emails`

Stores email data and AI-generated responses for the Email Management feature.

```
emails/
  ├── {emailId}/
  │     ├── subject: string
  │     ├── senderEmail: string
  │     ├── senderName: string
  │     ├── recipients: array<string>
  │     ├── body: string
  │     ├── receivedAt: timestamp
  │     ├── status: string (pending | responded | approved | rejected)
  │     ├── aiResponse: string
  │     ├── priority: number (1-3, with 1 being highest)
  │     ├── isRead: boolean
  │     ├── hasAttachments: boolean
  │     ├── attachmentUrls: array<string>
  │     ├── tags: array<string>
  │     ├── needsResponse: boolean
  │     ├── isSpam: boolean
  │     └── archived: boolean
```

### Collection: `email_tasks`

Stores tasks associated with emails.

```
email_tasks/
  ├── {taskId}/
  │     ├── title: string
  │     ├── description: string
  │     ├── sourceEmailId: string (reference to emails/{emailId})
  │     ├── createdDate: timestamp
  │     ├── dueDate: timestamp
  │     ├── status: string (todo | inProgress | completed)
  │     └── assignedTo: string
```

### Collection: `ai_insights`

Stores AI-generated insights and anomaly detections.

```
ai_insights/
  ├── {insightId}/
  │     ├── title: string
  │     ├── description: string
  │     ├── category: string
  │     ├── severity: string (info | warning | critical)
  │     ├── createdAt: timestamp
  │     ├── relatedData: object
  │     ├── isRead: boolean
  │     ├── actionTaken: boolean
  │     └── actionDetails: string
```

### Collection: `documents`

Stores metadata about generated documents.

```
documents/
  ├── {documentId}/
  │     ├── title: string
  │     ├── description: string
  │     ├── category: string
  │     ├── createdAt: timestamp
  │     ├── modifiedAt: timestamp
  │     ├── storageUrl: string
  │     ├── size: number
  │     ├── format: string
  │     └── generatedBy: string (userId)
```

### Collection: `chat_sessions`

Stores chat conversations with the AI assistant.

```
chat_sessions/
  ├── {sessionId}/
  │     ├── userId: string
  │     ├── startedAt: timestamp
  │     ├── lastActiveAt: timestamp
  │     ├── title: string
  │     └── messages: [
  │           {
  │             sender: string (user | ai),
  │             content: string,
  │             timestamp: timestamp,
  │             attachments: array<object>
  │           }
  │       ]
```

### Collection: `seo_data`

Stores SEO metrics and configuration.

```
seo_data/
  ├── overview/
  │     ├── organicTraffic: number
  │     ├── averageRank: number
  │     ├── impressions: number
  │     ├── clicks: number
  │     ├── ctr: number
  │     ├── conversionRate: number
  │     └── lastUpdated: timestamp
  │
  ├── keywords/
  │     ├── {keywordId}/
  │     │     ├── keyword: string
  │     │     ├── rank: number
  │     │     ├── previousRank: number
  │     │     ├── searchVolume: number
  │     │     ├── difficulty: number
  │     │     ├── cpc: number
  │     │     ├── impressions: number
  │     │     ├── clicks: number
  │     │     └── lastUpdated: timestamp
  │
  ├── pages/
  │     ├── {pageId}/
  │     │     ├── url: string
  │     │     ├── title: string
  │     │     ├── description: string
  │     │     ├── impressions: number
  │     │     ├── clicks: number
  │     │     ├── ctr: number
  │     │     ├── averageRank: number
  │     │     └── lastUpdated: timestamp
```

### Collection: `blog_content`

Stores blog content and performance metrics.

```
blog_content/
  ├── posts/
  │     ├── {postId}/
  │     │     ├── title: string
  │     │     ├── excerpt: string
  │     │     ├── content: string
  │     │     ├── author: string
  │     │     ├── publishDate: timestamp
  │     │     ├── status: string (draft | scheduled | published)
  │     │     ├── categories: array<string>
  │     │     ├── tags: array<string>
  │     │     ├── featuredImage: string
  │     │     └── metrics: {
  │     │           ├── views: number
  │     │           ├── averageTimeOnPage: number
  │     │           ├── socialShares: number
  │     │           ├── comments: number
  │     │           └── conversionRate: number
  │     │       }
  │
  ├── ideas/
  │     ├── {ideaId}/
  │     │     ├── title: string
  │     │     ├── description: string
  │     │     ├── targetKeywords: array<string>
  │     │     ├── estimatedImpact: string
  │     │     ├── suggestedBy: string
  │     │     ├── createdAt: timestamp
  │     │     ├── status: string (new | approved | rejected | inProgress | completed)
  │     │     └── assignedTo: string
```

### Collection: `ai_tasks`

Stores AI task execution logs and analytics.

```
ai_tasks/
  ├── logs/
  │     ├── {logId}/
  │     │     ├── taskType: string
  │     │     ├── startTime: timestamp
  │     │     ├── endTime: timestamp
  │     │     ├── duration: number
  │     │     ├── status: string (success | failure)
  │     │     ├── errorMessage: string
  │     │     ├── inputSize: number
  │     │     ├── outputSize: number
  │     │     ├── cost: number
  │     │     └── metadata: object
  │
  ├── analytics/
  │     ├── dailySummary: {
  │     │     ├── date: string
  │     │     ├── totalTasks: number
  │     │     ├── successRate: number
  │     │     ├── averageDuration: number
  │     │     ├── totalCost: number
  │     │     └── taskBreakdown: object
  │     │ }
  │     ├── monthlySummary: {
  │     │     ├── month: string
  │     │     ├── totalTasks: number
  │     │     ├── successRate: number
  │     │     ├── averageDuration: number
  │     │     ├── totalCost: number
  │     │     └── taskBreakdown: object
  │     │ }
```

## Firebase Storage Structure

```
/users/{userId}/profile_image       # User profile images
/emails/{emailId}/attachments/      # Email attachments
/documents/generated/               # Generated documents for download
/blog/images/                       # Blog post images
/uploads/                           # General file uploads
```

## Security Rules

Access to these database resources is controlled by the security rules defined in:

- `/flutter-app/firestore.rules` - Controls access to Firestore collections


## Index Configuration

Composite indexes required for complex queries are defined in:

- `/flutter-app/firestore.indexes.json`

Current indexes include:
- Email queries by archived status, spam status, and received date