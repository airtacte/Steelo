const db = require('../../../firebase-config');

class Stablecoin {
        constructor(data) {
            this.id = data.id;
            this.currencyName = data.currencyName;
            this.holderID = data.holderID;
            this.regulatoryInfo = data.regulatoryInfo;
            this.transactionInfo = data.transactionInfo;
        }

        validate() {
            if (!this.id || !this.currencyName || !this.holderID || !this.regulatoryInfo || !this.transactionInfo) {
                throw new Error('Missing required fields');
            }
        }
    
        static async fetchById(id) {
            if (!id) {
                throw new Error('Missing id');
            }
            const doc = await db.collection('stablecoins').doc(id).get();
            if (!doc.exists) {
                throw new Error('Stablecoin not found');
            }
            return new Stablecoin({ id: doc.id, ...doc.data() });
        }

        static async fetchByHolderID(holderID) {
            if (!holderID) {
                throw new Error('Missing holderID');
            }
            const snapshot = await db.collection('stablecoins').where('holderID', '==', holderID).get();
            if (snapshot.empty) {
                throw new Error('No matching stablecoins found');
            }
            return snapshot.docs.map(doc => new Stablecoin({ id: doc.id, ...doc.data() }));
        }
    
        async save() {
            this.validate();
            await db.collection('stablecoins').doc(this.id).set({ ...this });
        }
    
        async update(updateData) {
            if (!updateData || Object.keys(updateData).length === 0) {
                throw new Error('Missing update data');
            }
            await db.collection('stablecoins').doc(this.id).update(updateData);
        }
    
        async delete() {
            await db.collection('stablecoins').doc(this.id).delete();
        }
}

module.exports = Stablecoin;