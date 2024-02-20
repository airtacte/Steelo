const db = require('../../../firebase-config');

class Search {
    constructor(id, result, discoveryID, searchID, profileID, searchDate) {
      this.id = id;
      this.result = result;
      this.discoveryID = discoveryID;
      this.searchID = searchID;
      this.profileID = profileID;
      this.searchDate = searchDate;
    }
  
    async save() {
      await db.collection('searches').doc(this.id).set({
        result: this.result,
        discoveryID: this.discoveryID,
        searchID: this.searchID,
        profileID: this.profileID,
        searchDate: this.searchDate
      });
    }
  
    async update(data) {
        await db.collection('searches').doc(this.id).update(data);
    }

    async delete() {
        await db.collection('searches').doc(this.id).delete();
    }
}

module.exports = Search;  