import firestore from '@react-native-firebase/firestore';

  class FirestoreService {
      static addUser(userData) {
          return firestore()
              .collection("users")
              .add(userData)
              .then(docRef => console.log("User added with ID: ", docRef.id))
              .catch(error => console.error("Error adding user: ", error));
      }
  }

// Define the collection name as a constant
const COLLECTION_NAME = 'myCollection';

class FirestoreService {
  static addUser(userData) {
    return firestore()
      .collection("users")
      .add(userData)
      .then(docRef => console.log("User added with ID: ", docRef.id))
      .catch(error => console.error("Error adding user: ", error));
  }

  static async addDocument(field, value) {
    try {
      await firestore().collection(COLLECTION_NAME).add({
        [field]: value,
      });
      console.log('Document added successfully');
    } catch (error) {
      console.error('Error adding document: ', error);
    }
  }

  static async getDocuments() {
    try {
      const querySnapshot = await firestore().collection(COLLECTION_NAME).get();
      const documents = querySnapshot.docs.map(doc => doc.data());
      console.log(documents);
    } catch (error) {
      console.error('Error getting documents: ', error);
    }
  }
}

export default FirestoreService;
