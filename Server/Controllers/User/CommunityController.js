const CommunityService = require('../../Services/communityService'); 

// Fetch the entire community (investors) of the logged-in user.
exports.getCommunity = async (req, res) => {
    try {
        const userId = req.userId;  // Extracted from JWT/session.
        const community = await CommunityService.fetchCommunity(userId);
        res.status(200).json(community);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

// Fetch a specific investor's details from the user's community.
exports.getCommunityMember = async (req, res) => {
    try {
        const { memberId } = req.params;
        const memberDetails = await CommunityService.fetchMemberDetails(memberId);
        res.status(200).json(memberDetails);
    } catch (error) {
        res.status(500).send(error.message);
    }
};

// No need for adding or removing members manually since it's automated.