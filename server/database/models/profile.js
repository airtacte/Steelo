const db = require('../../../firebase-config');

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