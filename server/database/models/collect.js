const db = require('../../../firebase-config');

class Collect {
    constructor(data) {
      this.id = data.id;
      this.collectID = data.collectID;
      this.profileID = data.profileID;
      this.contentID = data.contentID;
      this.collectionDate = data.collectionDate;
    }
  
    static async fetchById(id) {
      const doc = await db.collection('collects').doc(id).get();
      if (!doc.exists) {
        throw new Error('Collect not found');
      }
      return new Collect({ id: doc.id, ...doc.data() });
    }
  
    async save() {
      await db.collection('collects').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      await db.collection('collects').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('collects').doc(this.id).delete();
    }
}

module.exports = Collect;  