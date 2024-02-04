import firestore from '@react-native-firebase/firestore';

class FirestoreService {
    static addUser(userData) {
        return firestore()
            .collection("users")
            .add(userData)
            .then(docRef => console.log("User added with ID: ", docRef.id))
            .catch(error => console.error("Error adding user: ", error));
    }

    const addDocument = async () => {
    await firestore().collection('myCollection').add({
      field: 'value', // replace with your field and value
    });
  };

const getDocuments = async () => {
    const querySnapshot = await firestore().collection('myCollection').get();
    const documents = querySnapshot.docs.map(doc => doc.data());
    console.log(documents);
  };

    // Other Firestore interactions can go here
}

export default FirestoreService;