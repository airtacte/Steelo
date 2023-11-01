const CollaboratorService = require('../services/CollaboratorService');

class MosaicCollaboratorController {
    async getCollaboratorList(req, res) {
        let collaborators = await CollaboratorService.getAllCollaborators();
        res.render('MosaicCollaboratorView', { collaborators: collaborators });
    }
}

module.exports = MosaicCollaboratorController;