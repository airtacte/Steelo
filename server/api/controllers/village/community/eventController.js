const express = require('express');
const EventService = require('../../../services/EventService'); // Assuming the path
const router = express.Router();

// Create event
router.post('/:id/event', async (req, res) => {
    try {
        const event = await EventService.createEvent(req.params.id, req.body);
        res.status(201).json(event);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;