# task

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

`dart run build_runner watch --delete-conflicting-outputs`

### Prototype and test with Firebase Local Emulator Suite
An Authentication emulator is part of the Local Emulator Suite, which enables your app to interact with emulated database content and config, as well as optionally your emulated project resources (functions, other databases, and security rules).
From the root directory, running `firebase emulators:start`. will spin up the env

### Firestore Security (Example)

In your Firebase console, set rules to restrict access and allow collaboration.

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /tasks/{taskId} {
      // Allow access only to authenticated users.
      // For collaboration, ensure the user is the owner or in the collaborators array.
      allow read, write: if request.auth != null &&
         (request.auth.uid == resource.data.ownerId ||
          (resource.data.collaboratorIds != null &&
           request.auth.uid in resource.data.collaboratorIds));
    }
  }
}
```

## Server setup

Reminders & Alerts via Cloud Functions

```js
// Cloud Function to send a reminder when a task is due soon.
exports.sendDueDateReminder = functions.firestore
    .document('tasks/{taskId}')
    .onUpdate((change, context) => {
      const newValue = change.after.data();
      // Check if the task’s due date is near and send an FCM notification.
      // Use the Firebase Admin SDK to send notifications.
    });
