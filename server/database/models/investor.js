const db = require('../../../firebase-config');

class Investor {
    constructor(id, profileID, taste, investorID, steezID, villageID, network) {
      this.id = id;
      this.investorID = investorID;
      this.network = network;
      this.profileID = profileID;
      this.steezID = steezID;
      this.taste = taste;
      this.villageID = villageID;
    }
  
    async save() {
      await db.collection('investors').doc(this.id).set({
        profileID: this.profileID,
        taste: this.taste,
        investorID: this.investorID,
        steezID: this.steezID,
        villageID: this.villageID,
        network: this.network,
      });
    }
  
    async update(data) {
        await db.collection('investors').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('investors').doc(this.id).delete();
    }
}

module.exports = Investor;  