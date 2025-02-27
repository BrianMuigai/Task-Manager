const functions = require("firebase-functions");
const admin = require("firebase-admin");
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Callable function to list all users.
 * WARNING: This function should be secured (e.g., only allow admin users)
 * in production. For testing purposes, it returns all users.
 */
exports.listUsers = functions.https.onCall(async (data, context) => {
  // Optionally, add security checks here.
  try {
    // List up to 1000 users (adjust as needed).
    const listUsersResult = await admin.auth().listUsers(1000);
    const users = listUsersResult.users.map((userRecord) => ({
      uid: userRecord.uid,
      displayName: userRecord.displayName || "",
      email: userRecord.email || "",
      photoUrl: userRecord.photoURL || "",
    }));
    return users;
  } catch (error) {
    throw new functions.https.HttpsError("internal", error.message, error);
  }
});
