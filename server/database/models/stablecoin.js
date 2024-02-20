const db = require('../../../firebase-config');

class Stablecoin {
  constructor(id, currencyName, holderID, regulatoryInfo, transactionInfo) {
    this.id = id;
    this.currencyName = currencyName;
    this.holderID = holderID; // { profileID: 'reference', verification: bool }
    this.regulatoryInfo = regulatoryInfo; // { AMLStatus: 'string', KYCStatus: 'string' }
    this.transactionInfo = transactionInfo; // { transactionLimits: number, transactionHistory: { owner1: { amount: number, profileID: 'reference', transactionID: 'reference' } } }
  }

  async save() {
    await db.collection('stablecoins').doc(this.id).set({
      currencyName: this.currencyName,
      holderID: this.holderID,
      regulatoryInfo: this.regulatoryInfo,
      transactionInfo: this.transactionInfo
    });
  }

  static async fetchById(id) {
    const doc = await db.collection('stablecoins').doc(id).get();
    if (!doc.exists) {
      throw new Error('Stablecoin not found');
    }
    return new Stablecoin(
      doc.id,
      doc.data().currencyName,
      doc.data().holderID,
      doc.data().regulatoryInfo,
      doc.data().transactionInfo
    );
  }

  async update(updateData) {
    await db.collection('stablecoins').doc(this.id).update(updateData);
  }

  async delete() {
    await db.collection('stablecoins').doc(this.id).delete();
  }
}

module.exports = Stablecoin;