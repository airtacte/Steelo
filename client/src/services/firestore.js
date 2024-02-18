import firestore from '@react-native-firebase/firestore';

// Constants for collection names
const USERS_COLLECTION = 'users';
const MY_COLLECTION = 'myCollection';

class FirestoreService {
  // Adds a user to the users collection
  static addUser(userData) {
    return firestore()
      .collection(USERS_COLLECTION)
      .add(userData)
      .then(docRef => {
        console.log("User added with ID: ", docRef.id);
        return docRef; // Return docRef for further processing if needed
      })
      .catch(error => {
        console.error("Error adding user: ", error);
        throw error; // Rethrow error to handle it in the calling component
      });
  }

  // Adds a document with specified field and value to MY_COLLECTION
  static addDocument(field, value) {
    return firestore()
      .collection(MY_COLLECTION)
      .add({ [field]: value })
      .then(docRef => {
        console.log('Document added successfully with ID:', docRef.id);
        return docRef; // Enable further processing with docRef
      })
      .catch(error => {
        console.error('Error adding document: ', error);
        throw error; // Allow calling component to handle the error
      });
  }

  // Retrieves all documents from MY_COLLECTION
  static getDocuments() {
    return firestore()
      .collection(MY_COLLECTION)
      .get()
      .then(querySnapshot => {
        const documents = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        console.log(documents);
        return documents; // Return documents for further use
      })
      .catch(error => {
        console.error('Error getting documents: ', error);
        throw error; // Allow error handling upstream
      });
  }

  // Example: Updating a document by ID
  static updateDocument(docId, newData) {
    return firestore()
      .collection(MY_COLLECTION)
      .doc(docId)
      .update(newData)
      .then(() => console.log('Document updated successfully'))
      .catch(error => {
        console.error('Error updating document: ', error);
        throw error;
      });
  }

  // Example: Deleting a document by ID
  static deleteDocument(docId) {
    return firestore()
      .collection(MY_COLLECTION)
      .doc(docId)
      .delete()
      .then(() => console.log('Document deleted successfully'))
      .catch(error => {
        console.error('Error deleting document: ', error);
        throw error;
      });
  }
}

export default FirestoreService;
