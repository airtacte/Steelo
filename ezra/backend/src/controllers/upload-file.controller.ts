import express, { Router } from "express";
import { initializeApp } from "firebase/app";
import { getStorage, ref, getDownloadURL, uploadBytesResumable } from "firebase/storage";
import multer from "multer";
import config from "../config/firebase.config"
import { addDoc, collection, doc, getDocs, getFirestore, query, where, documentId, setDoc } from "firebase/firestore";
const app = initializeApp(config.firebaseConfig);
const router: Router = express.Router();
const db = getFirestore(app);

//Initialize a firebase application
initializeApp(config.firebaseConfig);

// Initialize Cloud Storage and get a reference to the service
const storage = getStorage();

// Setting up multer as a middleware to grab photo uploads
const upload = multer({ storage: multer.memoryStorage() });
const cityRef = collection(db, "Videos");

router.post("/", upload.single("filename"), async (req, res) => {
    try {
        const dateTime = giveCurrentDateTime();

        const storageRef = ref(storage, `files/${req.file.originalname}`);

        // Create file metadata including the content type
        const metadata = {
            contentType: req.file.mimetype,
        };

        // Upload the file in the bucket storage
        const snapshot = await uploadBytesResumable(storageRef, req.file.buffer, metadata);
        //by using uploadBytesResumable we can control the progress of uploading like pause, resume, cancel

        // Grab the public url
        const downloadURL = await getDownloadURL(snapshot.ref);

        console.log('File successfully uploaded.');
        return res.send({
            message: 'file uploaded to firebase storage',
            name: req.file.originalname,
            type: req.file.mimetype,
            downloadURL: downloadURL
        })
    } catch (error) {
        return res.status(400).send(error.message)
    }
});

router.post('/video', upload.single("filename"), async (req, res) => {
    try {
        // Extracting city details and adding to the database
        

        // Handling file upload to Firebase Storage
        const dateTime = new Date().toISOString();
        const storageRef = ref(storage, `files/${dateTime}_${req.file.originalname}`);
        const metadata = { contentType: req.file.mimetype };
        const snapshot = await uploadBytesResumable(storageRef, req.file.buffer, metadata);
        const downloadURL = await getDownloadURL(snapshot.ref);

        console.log('File successfully uploaded.');

	const city = { name: req.body.name, state: req.body.state, country: req.body.country, videoUrl: downloadURL  };
        const docRef = await addDoc(cityRef, city);
        console.log("City document written with ID: ", docRef.id);

        // Sending response with city and file details
        return res.send({
            message: 'New city added to DB and file uploaded to Firebase storage',
            cityId: docRef.id,
            fileInfo: {
                name: req.file.originalname,
                type: req.file.mimetype,
                downloadURL: downloadURL
            }
        });
    } catch (error) {
        console.error("Error adding city or uploading file: ", error.message);
        return res.status(400).send(error.message);
    }
});

router.get("/video/:filename", async (req, res) => {
    try {
        const fileName = req.params.filename;
        const fileRef = ref(storage, `files/${fileName}`);

        // Retrieve the download URL
        const downloadURL = await getDownloadURL(fileRef);
        
        console.log(`Download URL retrieved: ${downloadURL}`);
        return res.send({
            message: "File retrieved successfully.",
            name: fileName,
            downloadURL: downloadURL
        });
    } catch (error) {
        console.error("Failed to retrieve file:", error);
        return res.status(500).send({
            message: "Failed to retrieve the file",
            error: error.message
        });
    }
});

const giveCurrentDateTime = () => {
    const today = new Date();
    const date = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
    const time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
    const dateTime = date + ' ' + time;
    return dateTime;
}

export default router;
