exports.uploadBlog = async (req, res) => {
    try {
      const db = getFirestore();
      const { title, content, author } = req.body;
      const docRef = await db.collection('blogs').add({
        title,
        content,
        author,
        timestamp: new Date(),
        // Additional fields as necessary, e.g., paywall
      });
      res.status(201).send(`Blog created with ID: ${docRef.id}`);
    } catch (error) {
      res.status(500).send('Error uploading blog');
    }
};  