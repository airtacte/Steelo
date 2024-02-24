const Highlight = require('../../models/Highlight');

exports.getHighlights = async (req, res) => {
  try {
    const highlights = await Highlight.find();
    res.json(highlights);
  } catch (error) {
    res.status(500).send(error.message);
  }
};

exports.addHighlight = async (req, res) => {
  try {
    const highlight = new Highlight(req.body);
    await highlight.save();
    res.status(201).send('Highlight added successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
};