const { getStorage } = require('firebase-admin/storage');
const { getFirestore } = require('firebase-admin/firestore');

exports.uploadContent = async (req, res) => {
  try {
    const file = req.file; // File uploaded via Multer
    const { userId, description } = req.body; // Assuming these are provided

    const storage = getStorage();
    const bucket = storage.bucket(); // Use default bucket, or specify if needed

    // Upload file to Firebase Storage
    const storageFile = await bucket.upload(file.path, {
      destination: `content/${file.originalname}`, // Customize path as needed
    });

    // Save content metadata in Firestore
    const db = getFirestore();
    const contentRef = await db.collection('content').add({
      userId,
      description,
      filePath: storageFile[0].metadata.fullPath,
      // Add any additional metadata as needed
    });

    res.status(201).send({ contentId: contentRef.id, ...storageFile[0].metadata });
  } catch (error) {
    console.error('Error uploading content:', error);
    res.status(500).send('Error uploading content.');
  }
};