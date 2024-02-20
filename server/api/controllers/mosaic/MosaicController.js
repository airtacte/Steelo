const ContentService = require('../services/ContentService');
const CollaboratorService = require('../services/CollaboratorService');

class MosaicController {
    async getMainPage(req, res) {
        let contents = await ContentService.getAllContents();
        res.render('MosaicMainView', { contents: contents });
    }
}

module.exports = MosaicController;