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