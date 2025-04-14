
## Firebase Realtime Database (RTDB)

Used for real-time features like notifications and status indicators.

```
/userStatus/
  ├── {userId}/
  │     ├── online: boolean
  │     ├── lastSeen: timestamp
  │     └── currentScreen: string

/notifications/
  ├── {userId}/
  │     ├── {notificationId}/
  │     │     ├── type: string
  │     │     ├── message: string
  │     │     ├── read: boolean
  │     │     ├── timestamp: timestamp
  │     │     └── data: object

/applicationStatus/
  ├── serverStatus: string (online | maintenance | degraded)
  ├── lastUpdated: timestamp
  ├── activeUsers: number
  └── maintenanceScheduled: timestamp
```

## Security Rules

Access to these database resources is controlled by the security rules defined in:

- `/database.rules.json` - Controls access to Realtime Database
