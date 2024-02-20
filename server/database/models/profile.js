const db = require('../../../firebase-config');

class Profile {
    constructor(data) {
      this.id = data.id;
      this.avatarURI = data.avatarURI;
      this.socialLinks = data.socialLinks;
      this.billingDetails = data.billingDetails;
      this.isVerified = data.isVerified;
      this.bio = data.bio;
      this.privacySettings = data.privacySettings;
      this.phone = data.phone;
      this.email = data.email;
      this.authentication = data.authentication;
      this.username = data.username;
      this.postingDetails = data.postingDetails;
      this.identificationProof = data.identificationProof;
      this.walletAddress = data.walletAddress;
      this.profileID = data.profileID;
    }
  
    static async fetchById(id) {
      const doc = await db.collection('profiles').doc(id).get();
      if (!doc.exists) {
        throw new Error('Profile not found');
      }
      return new Profile({ id: doc.id, ...doc.data() });
    }
  
    async save() {
      await db.collection('profiles').doc(this.id).set({ ...this });
    }
  
    async update(updateData) {
      await db.collection('profiles').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('profiles').doc(this.id).delete();
    }
}

module.exports = Profile;  