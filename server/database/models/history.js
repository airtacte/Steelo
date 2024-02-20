const db = require('../../../firebase-config');

class History {
    constructor(id, feedback, browseDate, viewingTime, historyID, profileID, creatorID) {
      this.id = id;
      this.browseDate = browseDate;
      this.creatorID = creatorID;
      this.feedback = feedback;
      this.historyID = historyID;
      this.profileID = profileID;
      this.viewingTime = viewingTime;
    }
  
    async save() {
      await db.collection('histories').doc(this.id).set({
        feedback: this.feedback,
        browseDate: this.browseDate,
        viewingTime: this.viewingTime,
        historyID: this.historyID,
        profileID: this.profileID,
        creatorID: this.creatorID,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('histories').doc(id).get();
      if (!doc.exists) {
        throw new Error('History not found');
      }
      return new History(doc.id, doc.data());
    }
  
    async update(data) {
        await db.collection('histories').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('histories').doc(this.id).delete();
    }
}

module.exports = History;  