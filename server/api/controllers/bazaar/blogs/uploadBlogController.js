exports.uploadBlog = async (req, res) => {
  try {
    const db = getFirestore();
    const { title, content, author, metadata, personalization, pricing, readerTargeting } = req.body;
    const docRef = await db.collection('blogs').add({
      title,
      content,
      author,
      metadata, // e.g., { keywords: ['keyword1', 'keyword2'], category: 'category1' }
      personalization, // e.g., { theme: 'dark', fontSize: 'medium' }
      pricing, // e.g., { price: 10, currency: 'STEEZ' }
      readerTargeting, // e.g., { ageGroup: '18-24', interests: ['interest1', 'interest2'] }
      timestamp: new Date(),
      // Additional fields as necessary, e.g., paywall
    });
    res.status(201).send(`Blog created with ID: ${docRef.id}`);
  } catch (error) {
    res.status(500).send('Error uploading blog');
  }
};