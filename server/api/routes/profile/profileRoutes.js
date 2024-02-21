const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');
const authMiddleware = require('../middleware/authMiddleware');

// Register user and create a new profile
router.post('/register', authMiddleware.validateToken, profileController.createProfile);

// Verify user (KYC)
router.post('/verify', authMiddleware.validateToken, profileController.verifyUser);

// Update profile information
router.put('/update', authMiddleware.validateToken, profileController.updateProfile);

// Upload content to profile
router.post('/content/upload', authMiddleware.validateToken, profileController.uploadContent);

// Update content within profile
router.put('/content/update', authMiddleware.validateToken, profileController.updateContent);

// Delete content from profile
router.delete('/content/delete', authMiddleware.validateToken, profileController.deleteContent);

// Fetch engagement data for the profile
router.get('/engagement', authMiddleware.validateToken, profileController.fetchEngagementData);

// Fetch analytics data for the creator
router.get('/analytics', authMiddleware.validateToken, profileController.generateAnalyticsReport);

// Manage $STEEZ (mint, track performance, etc.)
router.post('/steez/manage', authMiddleware.validateToken, profileController.manageSteez);

// Manage collaborations on projects
router.post('/collaborators/add', authMiddleware.validateToken, profileController.addCollaborator);
router.delete('/collaborators/remove', authMiddleware.validateToken, profileController.removeCollaborator);

// Fetch user profile by ID (public route)
router.get('/:userId', profileController.getProfileById);

module.exports = router;