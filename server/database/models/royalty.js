const db = require('../../../firebase-config');

class Royalty {
    constructor(id, profileID, saleType, developerRoyalty, communityRoyalty, royaltyID, tradePrice, tradeID) {
      this.id = id;
      this.profileID = profileID;
      this.saleType = saleType;
      this.developerRoyalty = developerRoyalty;
      this.communityRoyalty = communityRoyalty;
      this.royaltyID = royaltyID;
      this.tradePrice = tradePrice;
      this.tradeID = tradeID;
    }
  
    async save() {
      await db.collection('royalties').doc(this.id).set({
        profileID: this.profileID,
        saleType: this.saleType,
        developerRoyalty: this.developerRoyalty,
        communityRoyalty: this.communityRoyalty,
        royaltyID: this.royaltyID,
        tradePrice: this.tradePrice,
        tradeID: this.tradeID
      });
    }
  
    async update(data) {
        await db.collection('royalties').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('royalties').doc(this.id).delete();
    }
}

module.exports = Royalty;  