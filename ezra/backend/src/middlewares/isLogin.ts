import { getDocs, query, where, collection, getFirestore, documentId } from 'firebase/firestore';
import { initializeApp } from "firebase/app";
import config from "../config/firebase.config"
const verifyToken = require("../../utils/verifyToken");



const app = initializeApp(config.firebaseConfig);


const db = getFirestore(app);

const isLogin = async (req, res, next) => {

    try {

	const headerObj = req.headers;
	const token = headerObj?.authorization?.split(" ")[1];
	const verifiedToken = verifyToken(token);


        const userRef = collection(db, "user");
        const userQuery = query(userRef, where(documentId(), "==", verifiedToken.id));
        const userSnapshot = await getDocs(userQuery);

        if (userSnapshot.empty) {
            throw new Error("No creator found with this id");
        }

        const userData = userSnapshot.docs[0].data();
        req.userAuth = { id: verifiedToken.id, email: userData.email, role: userData.role };
        next();
    } catch (error) {
        return res.status(401).send({ message: "Invalid or expired token" });
    }
};

export default isLogin;
