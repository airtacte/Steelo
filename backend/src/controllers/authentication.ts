import { initializeApp } from "firebase/app";
import { addDoc, collection, doc, getDocs, getFirestore, query, where, documentId, setDoc, updateDoc, deleteDoc } from "firebase/firestore";
import config from "../config/firebase.config"
import { pick } from "lodash";
import express, { Router, Request, Response } from "express";
const bcrypt = require("bcryptjs");
const router: Router = express.Router();
const { hashPassword, isPassMatched } = require("../../utils/helpers");
const generateToken = require("../../utils/generateToken"); 

import isLogin from '../middlewares/isLogin'; 
import isCreator from '../middlewares/isCreator'; 
import isExecutive from '../middlewares/isExecutive'; 



const app = initializeApp(config.firebaseConfig);


const db = getFirestore(app);

const employeesRef = collection(db, "employee");
const userRef = collection(db, "user");



router.post('/register/executive', async (req: Request, res: Response) => {
    try {
        const { email } = req.body;
        const executiveQuery = query(userRef, where("email", "==", email));
        const existingExecutives = await getDocs(executiveQuery);

        if (!existingExecutives.empty) {
            return res.status(400).send('Executive already exists.');
        }

        const executive = { email: req.body.email, password: await hashPassword(req.body.password), role: "executive"  }
        const docRef = await addDoc(userRef, executive);
        console.log("Document written with ID: ", docRef.id);
        return res.send('New executive added to DB.')
    } catch (e) {
        return res.status(400).send(e.message)
    }
});


router.post('/register/creator', async (req: Request, res: Response) => {
    try {
        const { email } = req.body;
        const creatorQuery = query(userRef, where("email", "==", email));
        const existingCreators = await getDocs(creatorQuery);

        if (!existingCreators.empty) {
            return res.status(400).send('Creator already exists.');
        }

        const creator = { name: req.body.name, email: req.body.email, password: await hashPassword(req.body.password), role: "creator"  }
        const docRef = await addDoc(userRef, creator);
        console.log("Document written with ID: ", docRef.id);
        return res.send('New creator added to DB.')
    } catch (e) {
        return res.status(400).send(e.message)
    }
});

router.post('/register/user', async (req: Request, res: Response) => {
    try {
        const { email } = req.body;
        const userQuery = query(userRef, where("email", "==", email));
        const existingUsers = await getDocs(userQuery);

        if (!existingUsers.empty) {
            return res.status(400).send('User already exists.');
        }

        const user = { email: req.body.email, password: await hashPassword(req.body.password), role: "user"  }
        const docRef = await addDoc(userRef, user);
        console.log("Document written with ID: ", docRef.id);
        return res.send('New user added to DB.')
    } catch (e) {
        return res.status(400).send(e.message)
    }
});

router.post('/login', async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;
        const creatorQuery = query(userRef, where("email", "==", email));
        const querySnapshot = await getDocs(creatorQuery);

        if (querySnapshot.empty) {
            return res.status(400).send('Creator not found.');
        }

	const creatorData = querySnapshot.docs[0].data();
        const isMatched = await isPassMatched(password, creatorData.password);

	if(!isMatched) {
		return res.json({ message: "Invalid credentials"})
	}
	else {
	return res.json({ 
		userId: querySnapshot.docs[0].id,
		role: creatorData.role,
		email: email,
		token: generateToken(querySnapshot.docs[0].id),
		message: "user loggedin succesfully",
	});
});




router.get('/', isLogin, isExecutive, async (req: Request, res: Response) => {
    try {
        const querySnapshot = await getDocs(userRef);
        const records = [];
        querySnapshot.forEach((doc) => {
            records.push(doc.data());
        });
        return res.send({
            'users records': records
        });
    } catch (err) {
        res.status(400).send(err.message);
    }
})

router.get('/:id', isLogin, isExecutive, async (req: Request, res: Response) => {
    try {
        const userId = req.params.id

        const q = query(userRef, where(documentId(), "==", userId));

        const querySnapshot = await getDocs(q);
        if (querySnapshot.empty) {
            return res.send(`User with id ${userId} does not exists.`)
        }
        const userRecord = querySnapshot.docs[0].data();
        res.send({
            'user record': userRecord
        })
    } catch (error) {
        res.status(400).send(error.message)
    }
})

router.put('/:id', isLogin, isExecutive, async (req: Request, res: Response) => {
    try {
        const userId = req.params.id;
        const UpdatedUser = pick(req.body, ['role']);
        const q = query(userRef, where(documentId(), "==", userId));
        const querySnapshot = await getDocs(q);
        if (querySnapshot.empty) {
            return res.send(`User with id ${employeeId} does not exists.`)
        }
        await updateDoc(doc(db, "user", userId), UpdatedUser);
        res.send('User record edited.')
    } catch (error) {
        res.status(400).send(error.message)
    }
})

router.delete('/:id', isLogin, isExecutive, async (req: Request, res: Response) => {
    try {
        const userId = req.params.id;
        const querySnapshot = await getDocs(query(userRef, where(documentId(), "==", userId)));
        if (querySnapshot.empty) {
            return res.send(`User with id ${userId} does not exists.`)
        }
        await deleteDoc(doc(db, "user", userId));
        res.send('User records Deleted.')
    } catch (error) {
        res.status(400).send(error.message)
    }
})

export default router;
