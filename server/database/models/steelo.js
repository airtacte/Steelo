const db = require('../../../firebase-config');

class Steelo {
    constructor(id, mintAmount, marketCap, burnAmount, isDeflationary, burnRate, tokenSupply, lastMint, currentPrice, steeloID, transactionCount, lastBurn, mintRate) {
      this.id = id;
      this.burnAmount = burnAmount;
      this.burnRate = burnRate;
      this.currentPrice = currentPrice;
      this.isDeflationary = isDeflationary;
      this.lastBurn = lastBurn;
      this.lastMint = lastMint;
      this.marketCap = marketCap;
      this.mintAmount = mintAmount;
      this.mintRate = mintRate;
      this.steeloID = steeloID;
      this.tokenSupply = tokenSupply;
      this.transactionCount = transactionCount;
    }
  
    async save() {
      await db.collection('steelos').doc(this.id).set({
        burnAmount: this.burnAmount,
        burnRate: this.burnRate,
        currentPrice: this.currentPrice,
        isDeflationary: this.isDeflationary,
        lastBurn: this.lastBurn,
        lastMint: this.lastMint,
        marketCap: this.marketCap,
        mintAmount: this.mintAmount,
        mintRate: this.mintRate,
        steeloID: this.steeloID,
        tokenSupply: this.tokenSupply,
        transactionCount: this.transactionCount,
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