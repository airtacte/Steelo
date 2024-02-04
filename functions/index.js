const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.getVolumeData = functions.https.onRequest(async (request, response) => {
  const snapshot = await admin.firestore().collection("volume").get();
  const data = [];
  snapshot.forEach((doc) => {
    data.push(doc.data());
  });
  response.send(data);
});

exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});
