const express = require('express');
const ProfileService = require('../../../services/ProfileService'); // Assuming the path
const router = express.Router();

// Create profile
router.post('/', async (req, res) => {
  try {
    const profile = await ProfileService.createProfile(req.body);
    res.status(201).json(profile);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

module.exports = router;