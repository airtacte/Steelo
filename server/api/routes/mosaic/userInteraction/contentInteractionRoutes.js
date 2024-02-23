const express = require('express');
const router = express.Router();
const contentInteractionController = require('../../controllers/mosaic/userInteraction/contentInteractionController');

router.post('/like', contentInteractionController.likeContent);
router.post('/comment', contentInteractionController.commentOnContent);

module_modules = router;