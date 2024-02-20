const db = require('../../../firebase-config');

class Steelo {
    constructor(id, mintAmount, marketCap, burnAmount, isDeflationary, burnRate, tokenSupply, lastMint, currentPrice, steeloID, transactionCount, lastBurn, mintRate) {
      this.id = id;
      this.mintAmount = mintAmount;
      this.marketCap = marketCap;
      this.burnAmount = burnAmount;
      this.isDeflationary = isDeflationary;
      this.burnRate = burnRate;
      this.tokenSupply = tokenSupply;
      this.lastMint = lastMint;
      this.currentPrice = currentPrice;
      this.steeloID = steeloID;
      this.transactionCount = transactionCount;
      this.lastBurn = lastBurn;
      this.mintRate = mintRate;
    }
  
    async save() {
      await db.collection('steelos').doc(this.id).set({
        mintAmount: this.mintAmount,
        marketCap: this.marketCap,
        burnAmount: this.burnAmount,
        isDeflationary: this.isDeflationary,
        burnRate: this.burnRate,
        tokenSupply: this.tokenSupply,
        lastMint: this.lastMint,
        currentPrice: this.currentPrice,
        steeloID: this.steeloID,
        transactionCount: this.transactionCount,
        lastBurn: this.lastBurn,
        mintRate: this.mintRate
      });
    }
  
    static async fetchById(id) {
      const doc = await db.collection('steelos').doc(id).get();
      if (!doc.exists) {
        throw new Error('Steelo not found');
      }
      return new Steelo(doc.id, doc.data().mintAmount, doc.data().marketCap, doc.data().burnAmount, 
        doc.data().isDeflationary, doc.data().burnRate, doc.data().tokenSupply, doc.data().lastMint,
        doc.data().currentPrice, doc.data().steeloID, doc.data().transactionCount, doc.data().lastBurn,
        doc.data().mintRate);
    }
  
    async update(updateData) {
      await db.collection('steelos').doc(this.id).update(updateData);
    }
  
    async delete() {
      await db.collection('steelos').doc(this.id).delete();
    }
  }
  
  module.exports = Steelo;  