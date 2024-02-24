const { getFirestore } = require('firebase-admin/firestore');

exports.displayBlog = async (req, res) => {
  try {
    const db = getFirestore();
    const doc = await db.collection('blogs').doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).send('Blog not found');
    }

    const blogData = doc.data();

    // Fetch additional blog content data
    const contentData = await db.collection('blogContents')
                                 .where('blogId', '==', req.params.id)
                                 .get();

    if (contentData.empty) {
      return res.status(404).send('No content data found for the specified blog.');
    }

    let blogContent = [];
    contentData.forEach(doc => {
      const data = doc.data();
      blogContent.push({
        type: data.type, // e.g., 'text', 'image', 'video', 'audio'
        content: data.content, // e.g., text content, image URL, video URL, audio URL
      });
    });

    res.status(200).json({
      ...blogData,
      content: blogContent
    });
  } catch (error) {
    res.status(500).send('Error retrieving blog');
  }
};