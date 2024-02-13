const ContentService = require('../services/ContentService');

class MosaicContentViewerController {
    async getContentDetails(req, res) {
        let contentId = req.params.id;
        let content = await ContentService.getContentById(contentId);
        res.render('MosaicContentViewerView', { content: content });
    }
}

module.exports = MosaicContentViewerController;