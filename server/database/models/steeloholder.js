const db = require('../../../firebase-config');

class SteeloHolder {
  constructor(depositID, id, profileID, steeloAmount, steeloHolderID, steeloID, withdrawalID) {
    this.id = id;
    this.depositID = depositID;
    this.profileID = profileID;
    this.steeloAmount = steeloAmount;
    this.steeloHolderID = steeloHolderID;
    this.steeloID = steeloID;
    this.withdrawalID = withdrawalID;
  }

  async save() {
    await db.collection('steeloholders').doc(this.id).set({
      depositID: this.depositID,
      profileID: this.profileID,
      steeloAmount: this.steeloAmount,
      steeloHolderID: this.steeloHolderID,
      steeloID: this.steeloID,
      withdrawalID: this.withdrawalID
    });
  }

  static async fetchById(id) {
    const doc = await db.collection('steeloholders').doc(id).get();
    if (!doc.exists) {
      throw new Error('SteeloHolder not found');
    }
    return new SteeloHolder(
      doc.data().depositID,
      doc.id,
      doc.data().profileID,
      doc.data().steeloAmount,
      doc.data().steeloHolderID,
      doc.data().steeloID,
      doc.data().withdrawalID
    );
  }

  async update(updateData) {
    await db.collection('steeloholders').doc(this.id).update(updateData);
  }

  async delete() {
    await db.collection('steeloholders').doc(this.id).delete();
  }
}

module.exports = SteeloHolder;