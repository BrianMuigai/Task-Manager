const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendDueDateReminder = functions.firestore
    .document('tasks/{taskId}')
    .onUpdate((change, context) => {
      const newValue = change.after.data();
      const dueDate = newValue.dueDate ? new Date(newValue.dueDate.seconds * 1000) : null;
      if (dueDate && isDueSoon(dueDate)) {
        const payload = {
          notification: {
            title: 'Task Reminder',
            body: `Your task "${newValue.title}" is due soon.`,
          },
        };
        // Assuming each task document has an array field "collaboratorIds" and/or "ownerId"
        const tokens = getTokensForUsers(newValue.ownerId, newValue.collaboratorIds);
        return admin.messaging().sendToDevice(tokens, payload);
      }
      return null;
    });

function isDueSoon(dueDate) {
  // Customize logic: e.g. if the due date is within 1 hour.
  const now = new Date();
  return (dueDate - now) <= 60 * 60 * 1000;
}

function getTokensForUsers(ownerId, collaboratorIds) {
  // Lookup FCM tokens for the owner and collaborators.
  // This is an example placeholder; you need to store user tokens in your database.
  return ['token1', 'token2'];
}
