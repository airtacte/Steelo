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



const app = initializeApp(config.firebaseConfig);


const db = getFirestore(app);

const employeesRef = collection(db, "employee");
const creatorRef = collection(db, "creator");






router.post('/register/creator', async (req: Request, res: Response) => {
    try {
        const { email } = req.body;
        const creatorQuery = query(creatorRef, where("email", "==", email));
        const existingCreators = await getDocs(creatorQuery);

        if (!existingCreators.empty) {
            return res.status(400).send('Creator already exists.');
        }

        const creator = { email: req.body.email, password: await hashPassword(req.body.password), role: "creator"  }
        const docRef = await addDoc(creatorRef, creator);
        console.log("Document written with ID: ", docRef.id);
        return res.send('New creator added to DB.')
    } catch (e) {
        return res.status(400).send(e.message)
    }
});

router.post('/login', async (req: Request, res: Response) => {
    try {
        const { email, password } = req.body;
        const creatorQuery = query(creatorRef, where("email", "==", email));
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
		data: generateToken(querySnapshot.docs[0].id),
		message: "creator loggedin succesfully",
	});
});




router.get('/', isLogin, isCreator, async (req: Request, res: Response) => {
    try {
        const querySnapshot = await getDocs(employeesRef);
        const records = [];
        querySnapshot.forEach((doc) => {
            records.push(doc.data());
        });
        return res.send({
            'employees records': records
        });
    } catch (err) {
        res.status(400).send(err.message);
    }
})

router.get('/:id', async (req: Request, res: Response) => {
    try {
        const employeeId = req.params.id

        const q = query(employeesRef, where(documentId(), "==", employeeId));

        const querySnapshot = await getDocs(q);
        if (querySnapshot.empty) {
            return res.send(`Employee with id ${employeeId} does not exists.`)
        }
        const employeeRecord = querySnapshot.docs[0].data();
        res.send({
            'Employee record': employeeRecord
        })
    } catch (error) {
        res.status(400).send(error.message)
    }
})

router.put('/:id', async (req: Request, res: Response) => {
    try {
        const employeeId = req.params.id;
        const UpdatedEmployee = pick(req.body, ['name', 'age', 'position', 'isPermanent']);
        const q = query(employeesRef, where(documentId(), "==", employeeId));
        const querySnapshot = await getDocs(q);
        if (querySnapshot.empty) {
            return res.send(`Employee with id ${employeeId} does not exists.`)
        }
        await updateDoc(doc(db, "employee", employeeId), UpdatedEmployee);
        res.send('Employee record edited.')
    } catch (error) {
        res.status(400).send(error.message)
    }
})

router.delete('/:id', async (req: Request, res: Response) => {
    try {
        const employeeId = req.params.id;
        const querySnapshot = await getDocs(query(employeesRef, where(documentId(), "==", employeeId)));
        if (querySnapshot.empty) {
            return res.send(`Employee with id ${employeeId} does not exists.`)
        }
        await deleteDoc(doc(db, "employee", employeeId));
        res.send('Employee records Deleted.')
    } catch (error) {
        res.status(400).send(error.message)
    }
})

export default router;
