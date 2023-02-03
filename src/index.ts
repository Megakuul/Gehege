//Import types from Mongodb and express
import { Application, Request, Response } from 'express';
import { AnyError, Callback, Collection, Db, ObjectId } from 'mongodb';

const cookieParser = require("cookie-parser");
const crypto = require('crypto');
const dotenv = require('dotenv');
const express = require("express");
const cors = require("cors");

const salt = "CeNhqBmdww(&GEukPLYY";

const hashAlgorithm = "sha256";

const usernameHeader = "username";
const successString = "Success";
const failureString = "Failed";

const MongoClient = require('mongodb').MongoClient;

dotenv.config();

const PORT = process.env.PORT;
const DB_HOST = process.env.DB_HOST;
const DB_PORT = process.env.DB_PORT;
const DB_USER = process.env.DB_USER;
const DB_PASSWORD = process.env.DB_PASSWORD;
const DB_DATABASE = process.env.DB_DATABASE;

const app: Application = express();

app.use(cors());

app.use(cookieParser());
 
app.use(express.json());

const uri = `mongodb://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}`;

const client = new MongoClient(uri);

//Open mongodb connection
client.connect((err: Error) => {
    if (err) {
        console.log("An error occured: " + err);
        process.exit(4);
    }
});

const db: Db = client.db(DB_DATABASE);
const collection_gehege: Collection = db.collection('gehege');
const collection_users: Collection = db.collection('users');

//Start listener for API
app.listen(PORT, () => {
    console.log("server startet on port: " + PORT);
});

app.get("/getgehege", async (req: Request, res: Response) => {

    let gehege = await collection_gehege.find({}).toArray();

    res.json({
        gehege
    });
});

app.post("/donate", async (req: Request, res: Response) => {
    const body = req.body;
    const username = req.cookies.username;
    const token = req.cookies.token || null;

    let gehege = await collection_gehege.find({ name: body.gehegename }).toArray();

    authRequest(username, token, async (e, user) => {
        if (e!=undefined || user == null) {
            res.json({
                state: failureString,
                payload: user,
                error: "Token invalid"
            });
            return;
        }
        
        if (user.cash > 0) {
            try {
                //Update user cash
                collection_users.updateOne(
                    { _id: user._id },
                    {
                        $inc :{
                            cash: -Number(body.cash) 
                        }
                    }
                );
                //Update gehege cash
                collection_gehege.updateOne(
                    { _id: gehege[0]._id },
                    {
                        $inc :{
                            donations: Number(body.cash)
                        }
                    }
                );

                res.json({
                    state: successString,
                    error: null
                });
            } catch (Error) {
                console.log(Error);
                res.json({
                    state: failureString,
                    error: "An error occured while donating"
                });
            }
        } else {
            res.json({
                state: failureString,
                error: "User has not enough cash"
            });
        }
    });
});

app.post("/creategehege", async (req: Request, res: Response) => {
    const body = req.body;
    const username = req.cookies.username;
    const token = req.cookies.token || null;

    authRequest(username, token, async (e, user) => {
        if (e!=undefined || user == null) {
            res.json({
                state: failureString,
                payload: user,
                error: e
            });
            return;
        }

        if (user.administrator) {
            if (await creategehege(body.gehege_name, body.imageBase64String)) {
                res.json({
                    state: successString,
                    error: null
                });
            } else {
                res.json({
                    state: failureString,
                    error: "On error occured while creating the Gehege"
                });
            }
            return;
        }

        res.json({
            state: failureString,
            error: "User does not have the required privileges"
        });
    });
});

app.get("/getuserinfo", async (req: Request, res: Response) => {
    const username = req.cookies.username;
    const token = req.cookies.token || null;

    authRequest(username, token, (e, user) => {
        if (e!=undefined || user == null) {
            res.json({
                state: failureString,
                payload: user,
                error: e
            });
            return;
        }
        //Code to execute if everything worked well
        res.json({
            state: successString,
            payload: {
                username: user.username,
                description: user.description,
                cash: user.cash,
                administrator: user.administrator
            },
            error: null
        })
        return;
    });
});

app.post("/changeuserinfo", async (req: Request, res: Response) => {
    const body = req.body;
    const username = req.cookies.username;
    const token = req.cookies.token || null;
    const hash = crypto.createHash(hashAlgorithm);

    authRequest(username, token, (e, user) => {
        if (e!=undefined || user == null) {
            res.json({
                state: failureString,
                error: e
            });
            return;
        }
        
        hash.update(body.password + salt);
        collection_users.updateOne(
            {username: username}, {
                $set: {
                    username: body.username !== undefined ? body.username : user.username,
                    description: body.description !== undefined ? body.description : user.description,
                    password: body.password !== undefined ? hash.digest('hex') : user.password
                }
            }
        )
        res.json({
            state: successString,
            error: null
        })
        return;
    });
});

app.post("/signup", async (req: Request, res: Response) => {
    const body = req.body;
    const hash = crypto.createHash(hashAlgorithm);

    hash.update(body.password + salt);
    const hashed_password = hash.digest('hex');

    const user = {
        username: body.username,
        password: hashed_password,
        description: body.description,
        cash: 50,
        administrator: false
    }

    let usersWithSameUsername = await collection_users.find({ username: req.body.username }).toArray();

    if (usersWithSameUsername.length > 0) {
        res.json({
            state: failureString,
            error: "User already exists"
        });
        return;
    }

    let insertion = await collection_users.insertOne(user);
    if (insertion.acknowledged) {
        res.json({
            state: successString,
            error: null
        });
        return;
    }
    res.json({
        state: failureString,
        error: "An unknown error occured"
    });
});

app.post("/createtok", async (req: Request, res: Response) => {
    const body = req.body;
    
    let users = await collection_users.find({ username: body.username }).toArray();

    if (users.length == 0) {
        res.json({
            state: failureString,
            tok: null,
            error: "User does not exist"
        });
        return;
    }
    const user = users[0];
    const hash = crypto.createHash(hashAlgorithm);

    hash.update(body.password + salt);
    if (user.password == hash.digest('hex')) {
        //Create temporary token
        res.cookie("token", setToken(7, user._id));
        res.cookie("username", user.username);
        res.json({
            state: successString,
            error: null
        });
    } else {
        res.json({
            state: failureString,
            error: "wrong password"
        });
    }
});

async function creategehege(name: string, imageBase64String: string) {
    const gehege = {
        name: name,
        image: imageBase64String,
        donations: 0
    }

    let insertion = await collection_gehege.insertOne(gehege);
    if (insertion.acknowledged) {
        return true;
    }
    return false;
}

function setToken(daysTilExpire: number, userid: ObjectId) {
    try {
        let currentTime = Date.now()
        let expirationTime = new Date(currentTime)
        expirationTime.setDate(expirationTime.getDate() + daysTilExpire)
    
        const token: string = crypto.randomBytes(16).toString('hex');
    
        collection_users.updateOne(
            { _id: userid },
            {
                $set: {
                    token: token,
                    expirationDate: expirationTime
                }
            }
        );
        return token;
    } catch (error) {
        return error;
    }
}

async function authRequest(username: String, token: string, callback: Callback) {
    try {
        let users = await collection_users.find({ 
            username: username,
        }).toArray();

        if (await checkToken(users[0]._id, token)) {
            callback(undefined, users[0]);
        } else {
            callback(undefined, null);
        }
    } catch (e: any | undefined) {   
        callback(e, null);
    }
}

async function checkToken(userid: ObjectId, token: string) {
    let users = await collection_users.find({_id: userid}).toArray();

    if (await checkTokenExpirationTime(users[0]._id)) {
        if (users[0].token == token) {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

async function checkTokenExpirationTime(userid: ObjectId) {
    let users = await collection_users.find({_id: userid}).toArray();
    let currentTime = new Date(Date.now());
    let expirationTime = new Date(users[0].expirationDate);

    if (currentTime > expirationTime) {
        collection_users.updateOne(
            { _id: userid },
            {
                $unset: {
                    token: "",
                    expirationTime: ""
                }
            }
        )
        return false;
    }
    return true;
}

