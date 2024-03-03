const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Investor {
    constructor(data) {
      this.id = data.id;
      this.investorID = data.investorID;
      this.network = data.network;
      this.profileID = data.profileID;
      this.steezID = data.steezID;
      this.taste = data.taste;
      this.villageID = data.villageID;
    }

    validate() {
      if (!this.id || !this.investorID || !this.network || !this.profileID || !this.steezID || !this.taste || !this.villageID) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('investors').doc(id).get();
      if (!doc.exists) {
        throw new Error('Investor not found');
      }
      return new Investor({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('investors').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching investors found');
      }
      return snapshot.docs.map(doc => new Investor({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('investors').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('investors').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('investors').doc(this.id).delete();
    }
}

module.exports = Investor;