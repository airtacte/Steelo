import { getDocs, query, where, collection, getFirestore, documentId } from 'firebase/firestore';
import { initializeApp } from "firebase/app";
import config from "../config/firebase.config"



const app = initializeApp(config.firebaseConfig);


const db = getFirestore(app);

const isCreator = async (req, res, next) => {

	console.log(req.userAuth);
	const userId = req?.userAuth?.id
	const userRef = collection(db, "user");
	const creatorQuery = query(userRef, where(documentId(), "==", userId));
        const userSnapshot = await getDocs(creatorQuery);

        if (userSnapshot.empty) {
            throw new Error("No creator found with this id");
        }

        const adminFound = userSnapshot.docs[0].data();
	
	if (adminFound?.role === "creator" ) {
		next();
	}
	else {
		return res.status(401).send({ message: "Access denied creator only" });
	}

}


module.exports = isCreator;
