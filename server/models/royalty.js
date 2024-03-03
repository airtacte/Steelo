const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Royalty {
    constructor(data) {
      this.id = data.id;
      this.communityRoyalty = data.communityRoyalty;
      this.creatorRoyalty = data.creatorRoyalty;
      this.developerRoyalty = data.developerRoyalty;
      this.isEligibleForRoyalty = data.isEligibleForRoyalty;
      this.profileID = data.profileID;
      this.royaltyID = data.royaltyID;
      this.saleType = data.saleType;
      this.tradeID = data.tradeID;
      this.tradePrice = data.tradePrice;
    }

    validate() {
      if (!this.id || !this.communityRoyalty || !this.creatorRoyalty || !this.developerRoyalty || !this.isEligibleForRoyalty || !this.profileID || !this.royaltyID || !this.saleType || !this.tradeID || !this.tradePrice) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('royalties').doc(id).get();
      if (!doc.exists) {
        throw new Error('Royalty not found');
      }
      return new Royalty({ id: doc.id, ...doc.data() });
    }

    static async fetchByProfileID(profileID) {
      if (!profileID) {
        throw new Error('Missing profileID');
      }
      const snapshot = await db.collection('royalties').where('profileID', '==', profileID).get();
      if (snapshot.empty) {
        throw new Error('No matching royalties found');
      }
      return snapshot.docs.map(doc => new Royalty({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('royalties').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('royalties').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('royalties').doc(this.id).delete();
    }
}

module.exports = Royalty;