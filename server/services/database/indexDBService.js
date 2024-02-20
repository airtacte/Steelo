// IndexDBService.js - For client-side use in a web context

class IndexDBService {
    constructor(dbName, storeName) {
      this.dbName = dbName;
      this.storeName = storeName;
      this.db = null;
    }
  
    // Initialize the database
    async init() {
      if (!window.indexedDB) {
        console.error("IndexedDB is not supported by this browser.");
        return;
      }
      return new Promise((resolve, reject) => {
        const request = window.indexedDB.open(this.dbName, 1);
  
        request.onerror = (event) => {
          console.error("IndexedDB error:", event.target.errorCode);
          reject(event.target.errorCode);
        };
  
        request.onupgradeneeded = (event) => {
          const db = event.target.result;
          db.createObjectStore(this.storeName, { keyPath: "id" });
        };
  
        request.onsuccess = (event) => {
          this.db = event.target.result;
          console.log("IndexedDB initialized successfully");
          resolve();
        };
      });
    }
  
    // Add or update data in the store
    async putData(data) {
      return new Promise((resolve, reject) => {
        const transaction = this.db.transaction([this.storeName], "readwrite");
        const store = transaction.objectStore(this.storeName);
        const request = store.put(data);
  
        request.onsuccess = () => resolve();
        request.onerror = (event) => {
          console.error("Error writing data to IndexedDB:", event.target.errorCode);
          reject(event.target.errorCode);
        };
      });
    }
  
    // Retrieve data by ID
    async getData(id) {
      return new Promise((resolve, reject) => {
        const transaction = this.db.transaction([this.storeName]);
        const store = transaction.objectStore(this.storeName);
        const request = store.get(id);
  
        request.onsuccess = (event) => resolve(event.target.result);
        request.onerror = (event) => {
          console.error("Error reading data from IndexedDB:", event.target.errorCode);
          reject(event.target.errorCode);
        };
      });
    }
  
    // Delete data by ID
    async deleteData(id) {
      return new Promise((resolve, reject) => {
        const transaction = this.db.transaction([this.storeName], "readwrite");
        const store = transaction.objectStore(this.storeName);
        const request = store.delete(id);
  
        request.onsuccess = () => resolve();
        request.onerror = (event) => {
          console.error("Error deleting data from IndexedDB:", event.target.errorCode);
          reject(event.target.errorCode);
        };
      });
    }
  }
  
  // Example usage
  // const indexDBService = new IndexDBService('SteeloDB', 'users');
  // await indexDBService.init();  