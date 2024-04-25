import express, { Express } from "express";
import uploadRouter from "./controllers/upload-file.controller";
import employeeRouter from "./controllers/crud.controller";
import cityRouter from "./controllers/cities-crud.controller";
import creatorRouter from "./controllers/videoUpload";
import authRouter from "./controllers/authentication";
import bodyParser from "body-parser";
import * as dotenv from 'dotenv'
dotenv.config();

const isLogin = require("./middlewares/isLogin");



import data from "./data";

const app: Express = express();
app.set('view engine', 'ejs');

app.use(express.json()); 


app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));

app.get('/', (req, res) => {
    res.send('hello world.')
})

app.get('/v1/posts', (req, res) => res.status(200).send(data));

app.use('/auth', authRouter);
app.use('/creator', creatorRouter);
app.use('/upload', uploadRouter);
app.use('/employee', employeeRouter);
app.use('/city', cityRouter);

const port = process.env.PORT || 9000;
app.listen(port, () => {
    console.log(`Server is listening at port ${port}`);
})
