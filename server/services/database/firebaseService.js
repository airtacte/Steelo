const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

// Initialize Firebase Admin SDK
initializeApp();

// Get Firestore database instance
const db = getFirestore();

class FirebaseService {
  // Example: Add a new user to Firestore
  async addUser(userData) {
    try {
      const docRef = await db.collection("users").add(userData);
      return { id: docRef.id, ...userData };
    } catch (error) {
      console.error("Error adding user to Firestore:", error);
      throw new Error("Failed to add user.");
    }
  }

  // Example: Fetch a user by ID
  async getUserById(userId) {
    try {
      const doc = await db.collection("users").doc(userId).get();
      if (!doc.exists) {
        console.log("No such user found!");
        return null;
      } else {
        return { id: doc.id, ...doc.data() };
      }
    } catch (error) {
      console.error("Error fetching user from Firestore:", error);
      throw new Error("Failed to fetch user.");
    }
  }

  // Example: Update user data
  async updateUser(userId, userData) {
    try {
      await db.collection("users").doc(userId).update(userData);
      return { id: userId, ...userData };
    } catch (error) {
      console.error("Error updating user in Firestore:", error);
      throw new Error("Failed to update user.");
    }
  }

  // Example: Delete a user
  async deleteUser(userId) {
    try {
      await db.collection("users").doc(userId).delete();
      return { message: "User successfully deleted" };
    } catch (error) {
      console.error("Error deleting user from Firestore:", error);
      throw new Error("Failed to delete user.");
    }
  }
}

module.exports = new FirebaseService();