const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendStatusNotification = functions.firestore
  .document("statuses/{email}")
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    // If status is updated
    if (newValue.status !== previousValue.status) {
      const token = newValue.deviceToken;
      const status = newValue.status;

      const message = {
        notification: {
          title: "Status Updated",
          body: `Your child's status is now: ${status}`,
        },
        token: token,
      };

      try {
        await admin.messaging().send(message);
        console.log("Notification sent successfully");
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    }
  });
