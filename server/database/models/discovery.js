const db = require('../../../firebase-config');

class Discovery {
    constructor(id, result, discoveryDate, profileID, origin, creatorID) {
      this.id = id;
      this.creatorID = creatorID;
      this.discoveryDate = discoveryDate;
      this.origin = origin;
      this.profileID = profileID;
      this.result = result;
    }
  
    async save() {
      await db.collection('discoveries').doc(this.id).set({
        result: this.result,
        discoveryDate: this.discoveryDate,
        profileID: this.profileID,
        origin: this.origin,
        creatorID: this.creatorID,
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('discoveries').doc(id).get();
      if (!doc.exists) {
        throw new Error('Discovery not found');
      }
      return new Discovery(doc.id, doc.data());
    }
  
    async update(data) {
        await db.collection('discoveries').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('discoveries').doc(this.id).delete();
    }
}

module.exports = Discovery;  