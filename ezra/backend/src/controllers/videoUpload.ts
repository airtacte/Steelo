import express, { Router } from "express";
import { initializeApp } from "firebase/app";
import { getStorage, ref, getDownloadURL, uploadBytesResumable } from "firebase/storage";
import { runTransaction } from "firebase/firestore";
import multer from "multer";
import config from "../config/firebase.config"
import { addDoc, collection, doc, getDocs, getFirestore, query, where, documentId, setDoc, updateDoc, deleteDoc, getDoc } from "firebase/firestore";


const app = initializeApp(config.firebaseConfig);
const router: Router = express.Router();
const db = getFirestore(app);

initializeApp(config.firebaseConfig);

const storage = getStorage();

const upload = multer({ storage: multer.memoryStorage() });
const videoRef = collection(db, "CreatorVideos");



router.post('/video', upload.single("video"), async (req, res) => {
    try {

        const dateTime = new Date().toISOString();
        const storageRef = ref(storage, `creatorVideos/${dateTime}_${req.file.originalname}`);
        const metadata = { contentType: req.file.mimetype };
        const snapshot = await uploadBytesResumable(storageRef, req.file.buffer, metadata);
        const downloadURL = await getDownloadURL(snapshot.ref);

        console.log('Video successfully uploaded.');

	const creatorVideo = { name: req.body.name, creatorId: req.body.creatorId, likes: 0, comments: 0, description: req.body.description, shares: 0, url: downloadURL  };
        const docRef = await addDoc(videoRef, creatorVideo);
        console.log("Creator Video document written with ID: ", docRef.id);

        return res.send({
            message: 'New creator video added to DB and file uploaded to Firebase storage',
            videoId: docRef.id,
            fileInfo: {
                name: req.file.originalname,
                type: req.file.mimetype,
                downloadURL: downloadURL
            }
        });
    } catch (error) {
        console.error("Error adding creator video or uploading video: ", error.message);
        return res.status(400).send(error.message);
    }
});

router.get('/video/', async (req: Request, res: Response) => {
    try {
        const querySnapshot = await getDocs(videoRef);
        const records = [];
        querySnapshot.forEach((doc) => {
            records.push(doc.data());
        });
        return res.send({
            'video records': records
        });
    } catch (err) {
        res.status(400).send(err.message);
    }
})

router.get('/video/one', async (req, res) => {
    try {
        const creatorId = req.query.creatorId;

	console.log("req body", req.body);

        let videosQuery = videoRef;

        if (creatorId) {
            videosQuery = query(videoRef, where("creatorId", "==", creatorId));
        }

        const querySnapshot = await getDocs(videosQuery);
        const videos = [];
        querySnapshot.forEach(doc => {
            videos.push({ id: doc.id, ...doc.data() });
        });

        res.status(200).send({
            message: 'Videos fetched successfully',
            videos
        });
    } catch (error) {
        console.error("Failed to fetch videos: ", error);
        res.status(500).send({
            message: "Failed to fetch videos",
            error: error.message
        });
    }
});

router.get('/video/:id', async (req: Request, res: Response) => {
    try {
        const videoId = req.params.id

        const q = query(videoRef, where(documentId(), "==", videoId));

        const querySnapshot = await getDocs(q);
        if (querySnapshot.empty) {
            return res.send(`Videos with id ${videoId} does not exists.`)
        }
        const videoRecord = querySnapshot.docs[0].data();
        res.send({
            'Employee record': videoRecord
        })
    } catch (error) {
        res.status(400).send(error.message)
    }
})

router.put('/video/:id/like', async (req, res) => {
    try {
        const videoId = req.params.id;
        const videoDoc = doc(db, "CreatorVideos", videoId);
        
        await runTransaction(db, async (transaction) => {
            const videoSnapshot = await transaction.get(videoDoc);
            if (!videoSnapshot.exists()) {
                throw new Error("Video does not exist!");
            }
            const currentLikes = videoSnapshot.data().likes || 0;
            transaction.update(videoDoc, { likes: currentLikes + 1 });
        });

        res.status(200).send({ message: "Likes updated successfully" });
    } catch (error) {
        console.error("Error updating likes: ", error.message);
        res.status(500).send(error.message);
    }
});

router.put('/video/:id/unlike', async (req, res) => {
    try {
        const videoId = req.params.id;
        const videoDoc = doc(db, "CreatorVideos", videoId);
        
        await runTransaction(db, async (transaction) => {
            const videoSnapshot = await transaction.get(videoDoc);
            if (!videoSnapshot.exists()) {
                throw new Error("Video does not exist!");
            }
            const currentLikes = videoSnapshot.data().likes || 0;
	    if (currentLikes > 0) {
            	transaction.update(videoDoc, { likes: currentLikes - 1 });
	    }
        });

        res.status(200).send({ message: "Likes updated successfully" });
    } catch (error) {
        console.error("Error updating likes: ", error.message);
        res.status(500).send(error.message);
    }
});


router.post('/video/:id/comment', async (req, res) => {
    const videoId = req.params.id;
    const { userId, comment } = req.body;

    console.log("req body", req.body);
    
    if (!comment) {
        return res.status(400).send({ message: "Comment is required." });
    }

    try {
        const videoDoc = doc(db, "CreatorVideos", videoId);
        const videoSnapshot = await getDoc(videoDoc);

        if (!videoSnapshot.exists()) {
            throw new Error("Video does not exist!");
        }

        const commentRef = collection(db, "Comments");
        const newComment = {
            videoId,
            userId,
            comment,
            timestamp: new Date().toISOString()
        };

        const commentDoc = await addDoc(commentRef, newComment);
        console.log("Comment added with ID: ", commentDoc.id);
	await runTransaction(db, async (transaction) => {
            const videoSnapshot = await transaction.get(videoDoc);
            if (!videoSnapshot.exists()) {
                throw new Error("Video does not exist!");
            }
            const currentComments = videoSnapshot.data().comments || 0;
            transaction.update(videoDoc, { comments: currentComments + 1 });
        });

        res.status(200).send({ message: "Comment added successfully", commentId: commentDoc.id });
    } catch (error) {
        console.error("Error adding comment: ", error.message);
        res.status(500).send({ message: "Failed to add comment", error: error.message });
    }
});


router.delete('/video/:videoId/comment/:commentId', async (req, res) => {
    const { videoId, commentId } = req.params;

    try {
        const commentRef = doc(db, "Comments", commentId);
        const commentSnap = await getDoc(commentRef);

        if (!commentSnap.exists() || commentSnap.data().videoId !== videoId) {
            return res.status(404).send({ message: "Comment not found or does not belong to the specified video." });
        }

        await deleteDoc(commentRef);

        const videoDoc = doc(db, "CreatorVideos", videoId);
        await runTransaction(db, async (transaction) => {
            const videoSnapshot = await transaction.get(videoDoc);
            const currentComments = videoSnapshot.data().comments || 0;
            transaction.update(videoDoc, { comments: currentComments - 1 });
        });

	await runTransaction(db, async (transaction) => {
            const videoSnapshot = await transaction.get(videoDoc);
            if (!videoSnapshot.exists()) {
                throw new Error("Video does not exist!");
            }
            const currentComments = videoSnapshot.data().comments || 0;
	    if (currentComments > 0) {
            	transaction.update(videoDoc, { comments: currentComments - 1 });
	    }
        });

        res.send({ message: "Comment deleted successfully." });
    } catch (error) {
        console.error("Error deleting comment: ", error);
        res.status(500).send({ message: "Failed to delete comment", error: error.message });
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
