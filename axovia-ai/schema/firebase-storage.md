
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

- `/flutter-app/storage.rules` - Controls access to Firebase Storage

 