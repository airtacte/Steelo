const express = require('express');
const { uploadContent } = require('../controllers/contentController');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

const router = express.Router();

// Route for content upload
router.post('/upload', upload.single('file'), uploadContent);

module.exports = router;