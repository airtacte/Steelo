exports.getCategories = async (req, res) => {
    // Placeholder: Fetch categories from database
    res.json([{ id: 1, name: 'Art' }, { id: 2, name: 'Music' }]);
  };
  
  exports.addCategory = async (req, res) => {
    // Placeholder: Add a new category to the database
    res.status(201).send('Category added successfully');
  };  