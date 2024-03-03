const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class Profile {
    constructor(data) {
      this.id = data.id;
      this.authentication = data.authentication;
      this.avatarURI = data.avatarURI;
      this.billingDetails = data.billingDetails;
      this.bio = data.bio;
      this.email = data.email;
      this.identificationProof = data.identificationProof;
      this.isVerified = data.isVerified;
      this.phone = data.phone;
      this.postingDetails = data.postingDetails;
      this.privacySettings = data.privacySettings;
      this.profileID = data.profileID;
      this.socialLinks = data.socialLinks;
      this.username = data.username;
      this.walletAddress = data.walletAddress;
    }

    validate() {
      if (!this.id || !this.authentication || !this.avatarURI || !this.billingDetails || !this.bio || !this.email || !this.identificationProof || !this.isVerified || !this.phone || !this.postingDetails || !this.privacySettings || !this.profileID || !this.socialLinks || !this.username || !this.walletAddress) {
        throw new Error('Missing required fields');
      }
    }
  
    static async fetchById(id) {
      if (!id) {
        throw new Error('Missing id');
      }
      const doc = await db.collection('profiles').doc(id).get();
      if (!doc.exists) {
        throw new Error('Profile not found');
      }
      return new Profile({ id: doc.id, ...doc.data() });
    }

    static async fetchByUsername(username) {
      if (!username) {
        throw new Error('Missing username');
      }
      const snapshot = await db.collection('profiles').where('username', '==', username).get();
      if (snapshot.empty) {
        throw new Error('No matching profiles found');
      }
      return snapshot.docs.map(doc => new Profile({ id: doc.id, ...doc.data() }));
    }
  
    async save() {
      this.validate();
      await db.collection('profiles').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new Error('Missing update data');
      }
      await db.collection('profiles').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('profiles').doc(this.id).delete();
    }
}

module.exports = Profile;