const Review = require('../../models/Review');

exports.postReview = async (req, res) => {
  try {
    const review = new Review(req.body);
    await review.save();
    res.status(201).send('Review posted successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
};

exports.editReview = async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    if (review.userId !== req.user.id) {
      return res.status(403).send('You do not have permission to edit this review');
    }
    Object.assign(review, req.body);
    await review.save();
    res.send('Review updated successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
};

exports.deleteReview = async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    if (review.userId !== req.user.id) {
      return res.status(403).send('You do not have permission to delete this review');
    }
    await review.remove();
    res.send('Review deleted successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
};