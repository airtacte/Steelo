const FollowerModel = require('../../models/FollowerModel'); // Assuming you have a followers model. Adjust path accordingly.

exports.getUserFollowers = async (req, res) => {
    try {
        const userId = req.params.id;
        const followers = await FollowerModel.find({ followedUserId: userId });

        res.status(200).json(followers);
    } catch (error) {
        res.status(500).send('Server error.');
    }
};

exports.addFollower = async (req, res) => {
    try {
        const newFollower = new FollowerModel(req.body);
        const savedFollower = await newFollower.save();

        res.status(201).json(savedFollower);
    } catch (error) {
        res.status(500).send('Server error.');
    }
};

exports.removeFollower = async (req, res) => {
    try {
        const followerId = req.params.id;
        await FollowerModel.findByIdAndDelete(followerId);

        res.status(200).send('Follower removed.');
    } catch (error) {
        res.status(500).send('Server error.');
    }
};