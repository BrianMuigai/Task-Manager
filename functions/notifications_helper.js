const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Helper function to determine if a due date is within the next hour.
function isDueSoon(dueDateTime) {
  if (!dueDateTime) return false;
  // Convert Firestore Timestamp or date string to a Date object.
  const due = dueDateTime.toDate ? dueDateTime.toDate() : new Date(dueDateTime);
  const now = new Date();
  const diff = due - now;
  // Consider due soon if it's due within the next hour (and still in the future)
  return diff > 0 && diff <= 60 * 60 * 1000;
}

// Helper function to retrieve FCM tokens for the task owner and collaborators.
async function getUserTokens(ownerId, collaboratorIds = []) {
  const userIds = [ownerId, ...collaboratorIds];
  const tokens = [];
  const usersRef = admin.firestore().collection('users');
  
  // Retrieve tokens for each user.
  const promises = userIds.map(async uid => {
    try {
      const userDoc = await usersRef.doc(uid).get();
      if (userDoc.exists) {
        const data = userDoc.data();
        if (data && data.fcmToken) {
          tokens.push(data.fcmToken);
        }
      }
    } catch (error) {
      console.error(`Error retrieving token for uid ${uid}:`, error);
    }
  });
  await Promise.all(promises);
  return tokens;
}

// Cloud Function to send a reminder when a task is due soon.
exports.sendDueDateReminder = functions.firestore
  .document('tasks/{taskId}')
  .onUpdate(async (change, context) => {
    try {
      const newValue = change.after.data();
      console.log('Task updated:', newValue);
      
      // Ensure dueDateTime exists.
      if (!newValue || !newValue.dueDateTime) {
        console.log('No dueDateTime provided.');
        return null;
      }
      
      // Check if the task is due soon.
      if (!isDueSoon(newValue.dueDateTime)) {
        console.log('Task is not due soon.');
        return null;
      }
      
      // Get FCM tokens for the owner and collaborators.
      const tokens = await getUserTokens(newValue.ownerId, newValue.collaboratorIds);
      if (!tokens.length) {
        console.log('No user tokens found.');
        return null;
      }
      
      const payload = {
        notification: {
          title: 'Task Reminder',
          body: `Your task "${newValue.title}" is due soon.`,
        },
      };
      
      console.log('Sending notification to tokens:', tokens);
      const response = await admin.messaging().sendToDevice(tokens, payload);
      console.log('Notification sent successfully:', response);
      return null;
    } catch (error) {
      console.error('Error sending due date reminder:', error);
      throw new functions.https.HttpsError('unknown', error.message, error);
    }
  });
