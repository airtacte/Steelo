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

const upload = multer({ storage: multer.memoryStorage(),
			fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('video/') || file.mimetype.startsWith('image/') || file.mimetype.startsWith('creatorProfilePhotos/')) {
      cb(null, true);
    } else {
      cb(new Error('Not a video or image file!'), false);
    }
  }});

const multipleUpload = upload.fields([{ name: 'video', maxCount: 1 }, { name: 'thumbnail', maxCount: 1 }]);

const videoRef = collection(db, "CreatorVideos");
import isLogin from '../middlewares/isLogin'; 
import isCreator from '../middlewares/isCreator'; 
import isExecutive from '../middlewares/isExecutive';


const userRef = collection(db, "user");





router.post('/video', isLogin, isCreator, multipleUpload, async (req, res) => {
    try {

    const videoFile = req.files['video'][0];
    const thumbnailFile = req.files['thumbnail'][0];

    // Upload video
    const videoDateTime = new Date().toISOString();
    const videoStorageRef = ref(storage, `creatorVideos/${videoDateTime}_${videoFile.originalname}`);
    const videoMetadata = { contentType: videoFile.mimetype };
    const videoSnapshot = await uploadBytesResumable(videoStorageRef, videoFile.buffer, videoMetadata);
    const videoDownloadURL = await getDownloadURL(videoSnapshot.ref);

    // Upload thumbnail
    const thumbDateTime = new Date().toISOString();
    const thumbStorageRef = ref(storage, `creatorThumbnails/${thumbDateTime}_${thumbnailFile.originalname}`);
    const thumbMetadata = { contentType: thumbnailFile.mimetype };
    const thumbSnapshot = await uploadBytesResumable(thumbStorageRef, thumbnailFile.buffer, thumbMetadata);
    const thumbDownloadURL = await getDownloadURL(thumbSnapshot.ref);

    console.log('Video and thumbnail successfully uploaded.');


	const creatorVideo = { name: req.body.name, creatorId: req.body.creatorId, likes: 0, comments: 0, description: req.body.description, shares: 0, videoUrl: videoDownloadURL, thumbnailUrl: thumbDownloadURL  };
        const docRef = await addDoc(videoRef, creatorVideo);
        console.log("Creator Video document written with ID: ", docRef.id);

        return res.send({
            message: 'New creator video added to DB and file uploaded to Firebase storage',
            videoId: docRef.id,
            fileInfo: {
                name: videoFile.originalname,
                type: videoFile.mimetype,
                downloadURL: videoDownloadURL
            }
        });
    } catch (error) {
        console.error("Error adding creator video or uploading video: ", error.message);
        return res.status(400).send(error.message);
    }
});


router.put('/profile/:id', isLogin, isCreator,  upload.single("photo"), async (req, res) => {
    try {
	const userId = req.params.id

        const Q = query(userRef, where(documentId(), "==", userId));

        const querySnapshotOld = await getDocs(Q);
        if (querySnapshotOld.empty) {
            return res.send(`User with id ${userId} does not exists.`)
        }
        const userRecord = querySnapshotOld.docs[0].data();
	let downloadURL = userRecord.profile ? userRecord.profile : "";
	let name =  userRecord.name;

	    if (req.file) {
	        const dateTime = new Date().toISOString();
	        const storageRef = ref(storage, `creatorProfilePhotos/${dateTime}_${req.file.originalname}`);
	        const metadata = { contentType: req.file.mimetype };
	        const snapshot = await uploadBytesResumable(storageRef, req.file.buffer, metadata);
	        downloadURL = await getDownloadURL(snapshot.ref);

        	console.log('Photo successfully uploaded.');
	    }

	
        const UpdatedUser = { profile: downloadURL, name: req.body.name ? req.body.name : name  };
        const q = query(userRef, where(documentId(), "==", userId));
        const querySnapshot = await getDocs(q);
        if (querySnapshot.empty) {
            return res.send(`User with id ${userId} does not exists.`)
        }
        await updateDoc(doc(db, "user", userId), UpdatedUser);
        res.send('User record edited.')
    } catch (error) {
        console.error("Error adding creator profile photo or uploading photo: ", error.message);
        return res.status(400).send(error.message);
    }
});



router.get('/video/', async (req, res) => {
    try {
        const querySnapshot = await getDocs(videoRef);
        const records = [];
        querySnapshot.forEach((doc) => {
            // Include the document ID with the rest of the document data
            const dataWithId = {
                id: doc.id,
                ...doc.data()
            };
            records.push(dataWithId);
        });
        return res.send({
            videos: records
        });
    } catch (err) {
        res.status(400).send(err.message);
    }
});

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
            video: videoRecord
        })
    } catch (error) {
        res.status(400).send(error.message)
    }
})

router.delete('/video/:id', isLogin, isCreator, async (req, res) => {
    const videoId = req.params.id;

    try {
        const q = query(videoRef, where(documentId(), '==', videoId));
        const querySnapshot = await getDocs(q);

        if (querySnapshot.empty) {
            return res.status(404).send(`Video with id ${videoId} does not exist.`);
        }

        await deleteDoc(doc(videoRef, querySnapshot.docs[0].id));
        res.send(`Video with id ${videoId} has been successfully deleted.`);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

router.put('/video/:id/like', isLogin, async (req, res) => {
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

router.put('/video/:id/unlike', isLogin, async (req, res) => {
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


router.post('/video/:id/comment', isLogin, async (req, res) => {
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


router.delete('/video/:videoId/comment/:commentId', isLogin, async (req, res) => {
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
