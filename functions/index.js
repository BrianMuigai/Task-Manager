/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Import our helper functions from notifications_helper.js
const notificationsHelper = require("./notifications_helper");

// Export the Cloud Function defined in notifications_helper.js
exports.sendDueDateReminder = notificationsHelper.sendDueDateReminder;
