const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Search {
    constructor(data) {
      this.id = data.id;
      this.discoveryID = data.discoveryID;
      this.profileID = data.profileID;
      this.result = data.result;
      this.searchDate = data.searchDate;
      this.searchID = data.searchID;
    }

    validate() {
      if (!this.id || !this.discoveryID || !this.profileID || !this.result || !this.searchDate || !this.searchID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('searches').doc(id).get();
      if (!doc.exists) {
        throw new Error('Search not found');
      }
      return new Search({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('searches').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching searches found');
      }
      return snapshot.docs.map(doc => new Search({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('searches').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('searches').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('searches').doc(this.id).delete();
    }
}

module.exports = Search;