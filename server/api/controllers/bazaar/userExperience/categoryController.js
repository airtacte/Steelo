const Category = require('../../models/Category');

exports.getCategories = async (req, res) => {
  try {
    const categories = await Category.find();
    res.json(categories);
  } catch (error) {
    res.status(500).send(error.message);
  }
};

exports.addCategory = async (req, res) => {
  try {
    const category = new Category(req.body);
    await category.save();
    res.status(201).send('Category added successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
};