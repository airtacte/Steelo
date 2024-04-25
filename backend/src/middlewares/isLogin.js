"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const jsonwebtoken_1 = require("jsonwebtoken");
const firestore_1 = require("firebase/firestore");
const app_1 = require("firebase/app");
const firebase_config_1 = __importDefault(require("../config/firebase.config"));
const app = (0, app_1.initializeApp)(firebase_config_1.default.firebaseConfig);
const db = getFirestore(app);
const isLogin = (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b;
    const token = (_b = (_a = req.headers) === null || _a === void 0 ? void 0 : _a.authorization) === null || _b === void 0 ? void 0 : _b.split(" ")[1];
    if (!token) {
        return res.status(401).send({ message: "No token provided" });
    }
    try {
        const decoded = (0, jsonwebtoken_1.verify)(token, "your_secret_key");
        const userRef = (0, firestore_1.collection)(db, "users");
        const userQuery = (0, firestore_1.query)(userRef, (0, firestore_1.where)("id", "==", decoded.id));
        const userSnapshot = yield (0, firestore_1.getDocs)(userQuery);
        if (userSnapshot.empty) {
            throw new Error("No user found with this id");
        }
        const userData = userSnapshot.docs[0].data();
        req.userAuth = { id: userData.id, email: userData.email, role: userData.role };
        next();
    }
    catch (error) {
        return res.status(401).send({ message: "Invalid or expired token" });
    }
});
exports.default = isLogin;
