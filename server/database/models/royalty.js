const db = require('../../../firebase-config');

class Royalty {
    constructor(id, profileID, saleType, developerRoyalty, communityRoyalty, royaltyID, tradePrice, tradeID) {
      this.id = id;
      this.communityRoyalty = communityRoyalty;
      this.creatorRoyalty = creatorRoyalty;
      this.developerRoyalty = developerRoyalty;
      this.isEligibleForRoyalty = isEligibleForRoyalty;
      this.profileID = profileID;
      this.royaltyID = royaltyID;
      this.saleType = saleType;
      this.tradeID = tradeID;
      this.tradePrice = tradePrice;
    }
  
    async save() {
      await db.collection('royalties').doc(this.id).set({
        profileID: this.profileID,
        saleType: this.saleType,
        communityRoyalty: this.communityRoyalty,
        creatorcreatorRoyalty: this.creatorRoyalty,
        developerRoyalty: this.developerRoyalty,
        isEligibleForRoyalty: this.isEligibleForRoyalty,
        royaltyID: this.royaltyID,
        tradePrice: this.tradePrice,
        tradeID: this.tradeID,
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