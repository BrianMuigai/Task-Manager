const functions = require('firebase-functions/v2');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Determines if the provided due date/time is within the next hour.
 *
 * @param {Object} dueDateTime - A Firestore Timestamp or date string representing the due date/time.
 * @returns {boolean} True if the due date is within the next hour (and still in the future), false otherwise.
 */
function isDueSoon(dueDateTime) {
  if (!dueDateTime) return false;
  const due = dueDateTime.toDate ? dueDateTime.toDate() : new Date(dueDateTime);
  const now = new Date();
  const diff = due - now;
  return diff > 0 && diff <= 60 * 60 * 1000;
}

/**
 * Retrieves FCM tokens for the task owner and collaborators from Firestore.
 *
 * @param {string} ownerId - The UID of the task owner.
 * @param {string[]} [collaboratorIds=[]] - An array of UIDs for the task collaborators.
 * @returns {Promise<string[]>} A promise that resolves to an array of FCM tokens.
 */
async function getUserTokens(ownerId, collaboratorIds = []) {
  const userIds = [ownerId, ...collaboratorIds];
  const tokens = [];
  const usersRef = admin.firestore().collection('users');

  const promises = userIds.map(async (uid) => {
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

/**
 * Cloud Function that sends a reminder notification when a task's due date is near.
 *
 * This function triggers on updates to documents in the 'tasks' collection.
 * It checks if the task's due date (dueDateTime) is within the next hour using `isDueSoon()`.
 * If so, it retrieves the FCM tokens for the task owner and collaborators, then sends a push notification.
 *
 * @function sendDueDateReminder
 * @param {object} event - The event payload, containing data.before and data.after.
 * @returns {Promise<null>} Resolves to null after processing.
 * @throws {functions.https.HttpsError} If an error occurs during notification sending.
 */
exports.sendDueDateReminder = onDocumentUpdated("tasks/{taskId}", async (event) => {
  try {
    // In v2, access updated data via event.data.after.data()
    const newValue = event.data.after.data();
    console.log("Task updated:", newValue);

    if (!newValue || !newValue.dueDateTime) {
      console.log("No dueDateTime provided.");
      return null;
    }

    if (!isDueSoon(newValue.dueDateTime)) {
      console.log("Task is not due soon.");
      return null;
    }

    const tokens = await getUserTokens(newValue.ownerId, newValue.collaboratorIds);
    if (!tokens.length) {
      console.log("No user tokens found.");
      return null;
    }

    const payload = {
      notification: {
        title: "Task Reminder",
        body: `Your task "${newValue.title}" is due soon.`,
      },
    };

    console.log("Sending notification to tokens:", tokens);
    const response = await admin.messaging().sendToDevice(tokens, payload);
    console.log("Notification sent successfully:", response);
    return null;
  } catch (error) {
    console.error("Error sending due date reminder:", error);
    throw new functions.https.HttpsError("unknown", error.message, error);
  }
});
