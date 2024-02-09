const UserModel = require('../../models/UserModel'); // Assuming you have a user model. Adjust path accordingly.

exports.getUserProfile = async (req, res) => {
    try {
        const userId = req.params.id;
        const user = await UserModel.findById(userId);
        
        if (!user) {
            return res.status(404).send('User not found.');
        }

        res.status(200).json(user);
    } catch (error) {
        res.status(500).send('Server error.');
    }
};

exports.updateUserProfile = async (req, res) => {
    try {
        const userId = req.params.id;
        const updatedData = req.body;
        const user = await UserModel.findByIdAndUpdate(userId, updatedData, { new: true });
        
        res.status(200).json(user);
    } catch (error) {
        res.status(500).send('Server error.');
    }
};