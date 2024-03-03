const db = require('../../../firebase-config');
const { ObjectId } = require('mongodb');
const connectDB = require('../../../config/db'); 

class SteeloHolder {
        constructor(data) {
            this.id = data.id;
            this.depositID = data.depositID;
            this.profileID = data.profileID;
            this.steeloAmount = data.steeloAmount;
            this.steeloHolderID = data.steeloHolderID;
            this.steeloID = data.steeloID;
            this.withdrawalID = data.withdrawalID;
        }

        validate() {
            if (!this.id || !this.depositID || !this.profileID || !this.steeloAmount || !this.steeloHolderID || !this.steeloID || !this.withdrawalID) {
                throw new Error('Missing required fields');
            }
        }
    
        static async fetchById(id) {
            if (!id) {
                throw new Error('Missing id');
            }
            const doc = await db.collection('steeloholders').doc(id).get();
            if (!doc.exists) {
                throw new Error('SteeloHolder not found');
            }
            return new SteeloHolder({ id: doc.id, ...doc.data() });
        }

        static async fetchByProfileID(profileID) {
            if (!profileID) {
                throw new Error('Missing profileID');
            }
            const snapshot = await db.collection('steeloholders').where('profileID', '==', profileID).get();
            if (snapshot.empty) {
                throw new Error('No matching steeloholders found');
            }
            return snapshot.docs.map(doc => new SteeloHolder({ id: doc.id, ...doc.data() }));
        }
    
        async save() {
            this.validate();
            await db.collection('steeloholders').doc(this.id).set({ ...this });
        }
    
        async update(updateData) {
            if (!updateData || Object.keys(updateData).length === 0) {
                throw new Error('Missing update data');
            }
            await db.collection('steeloholders').doc(this.id).update(updateData);
        }
    
        async delete() {
            await db.collection('steeloholders').doc(this.id).delete();
        }
}

module.exports = SteeloHolder;