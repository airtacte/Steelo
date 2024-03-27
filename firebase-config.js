import { initializeApp } from "firebase-admin/app";
import { getAppCheck } from "firebase-admin/app-check";

const { firebaseConfig } = require('./config/config.js');

// Initialize Firebase
const firebaseApp = initializeApp(firebaseConfig);

async function appCheckVerification(req, res, next) {
  const appCheckToken = req.header("X-Firebase-AppCheck");

  if (!appCheckToken) {
    res.status(401);
    return next("Unauthorized");
  }

  try {
    const appCheckClaims =
      await getAppCheck(firebaseApp).verifyToken(appCheckToken);

    // If verifyToken() succeeds, continue with the next middleware
    // function in the stack.
    return next();
  } catch (err) {
    res.status(401);
    return next("Unauthorized");
  }
}

export default { firebaseApp, appCheckVerification };
