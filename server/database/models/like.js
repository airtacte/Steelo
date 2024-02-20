const db = require('../../../firebase-config');

class Like {
    constructor(data) {
      this.id = data.id;
      this.profileID = data.profileID;
      this.contentID = data.contentID;
      this.likeDate = data.likeDate;
      this.likeID = data.likeID;
      this.likeSpeed = data.likeSpeed;
    }

    validate() {
      if (!this.id || !this.profileID || !this.contentID || !this.likeDate || !this.likeID || !this.likeSpeed) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('likes').doc(id).get();
      if (!doc.exists) {
        throw new Error('Like not found');
      }
      return new Like({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('likes').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching likes found');
      }
      return snapshot.docs.map(doc => new Like({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('likes').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('likes').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('likes').doc(this.id).delete();
    }
}

module.exports = Like;