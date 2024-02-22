const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');

// User registration handler
exports.registerUser = async (req, res) => {
  try {
    const { email, password, username } = req.body;
    const auth = getAuth();
    
    // Create user in Firebase Authentication
    const userRecord = await auth.createUser({
      email,
      password
    });

    // Store additional user information in Firestore
    const db = getFirestore();
    await db.collection('users').doc(userRecord.uid).set({
      username,
      email,
      // Add any additional fields as needed
    });

    res.status(201).send({ userId: userRecord.uid, email, username });
  } catch (error) {
    console.error('Error registering user:', error);
    res.status(500).send('Error registering user.');
  }
};