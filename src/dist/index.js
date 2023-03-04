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
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
var cookieParser = require("cookie-parser");
var crypto = require('crypto');
var dotenv = require('dotenv');
var express = require("express");
var cors = require("cors");
var salt = "CeNhqBmdww(&GEukPLYY";
var hashAlgorithm = "sha256";
var usernameHeader = "username";
var successString = "Success";
var failureString = "Failed";
var MongoClient = require('mongodb').MongoClient;
dotenv.config();
var PORT = process.env.PORT;
var DB_HOST = process.env.DB_HOST;
var DB_PORT = process.env.DB_PORT;
var DB_USER = process.env.DB_USER;
var DB_PASSWORD = process.env.DB_PASSWORD;
var DB_DATABASE = process.env.DB_DATABASE;
var GEHEGE_ADMIN = process.env.GEHEGE_ADMIN;
var GEHEGE_ADMIN_PW = process.env.GEHEGE_ADMIN_PW;
var app = express();
app.use(cors());
app.use(cookieParser());
app.use(express.json());
// Serve static files from the "public" directory
app.use(express.static('public'));
var uri = "mongodb://".concat(DB_USER, ":").concat(DB_PASSWORD, "@").concat(DB_HOST, ":").concat(DB_PORT);
var client = new MongoClient(uri);
//Open mongodb connection
client.connect(function (err) {
    if (err) {
        console.log("An error occured: " + err);
        process.exit(4);
    }
});
var db = client.db(DB_DATABASE);
var collection_gehege = db.collection('gehege');
var collection_users = db.collection('users');
//Start listener for API
app.listen(PORT, function () {
    return __awaiter(this, void 0, void 0, function () {
        var _a, _b;
        return __generator(this, function (_c) {
            switch (_c.label) {
                case 0:
                    console.log("server startet on port: " + PORT);
                    _b = (_a = console).log;
                    return [4 /*yield*/, createuser(GEHEGE_ADMIN || "admin", "", GEHEGE_ADMIN_PW || "admin", 4096, true)];
                case 1:
                    _b.apply(_a, [_c.sent()]);
                    return [2 /*return*/];
            }
        });
    });
});
app.get("/getgehege", function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var gehege;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, collection_gehege.find({}).toArray()];
            case 1:
                gehege = _a.sent();
                res.json({
                    gehege: gehege
                });
                return [2 /*return*/];
        }
    });
}); });
app.post("/donate", function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var body, username, token, gehege;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                body = req.body;
                username = req.cookies.username;
                token = req.cookies.token || null;
                return [4 /*yield*/, collection_gehege.find({ name: body.gehegename }).toArray()];
            case 1:
                gehege = _a.sent();
                authRequest(username, token, function (e, user) { return __awaiter(void 0, void 0, void 0, function () {
                    return __generator(this, function (_a) {
                        if (e != undefined || user == null) {
                            res.json({
                                state: failureString,
                                payload: user,
                                error: "Token invalid"
                            });
                            return [2 /*return*/];
                        }
                        if (user.cash > 0) {
                            try {
                                //Update user cash
                                collection_users.updateOne({ _id: user._id }, {
                                    $inc: {
                                        cash: -Number(body.cash)
                                    }
                                });
                                //Update gehege cash
                                collection_gehege.updateOne({ _id: gehege[0]._id }, {
                                    $inc: {
                                        donations: Number(body.cash)
                                    }
                                });
                                res.json({
                                    state: successString,
                                    error: null
                                });
                            }
                            catch (Error) {
                                console.log(Error);
                                res.json({
                                    state: failureString,
                                    error: "An error occured while donating"
                                });
                            }
                        }
                        else {
                            res.json({
                                state: failureString,
                                error: "User has not enough cash"
                            });
                        }
                        return [2 /*return*/];
                    });
                }); });
                return [2 /*return*/];
        }
    });
}); });
app.post("/creategehege", function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var body, username, token;
    return __generator(this, function (_a) {
        body = req.body;
        username = req.cookies.username;
        token = req.cookies.token || null;
        authRequest(username, token, function (e, user) { return __awaiter(void 0, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (e != undefined || user == null) {
                            res.json({
                                state: failureString,
                                payload: user,
                                error: e
                            });
                            return [2 /*return*/];
                        }
                        if (!user.administrator) return [3 /*break*/, 2];
                        return [4 /*yield*/, creategehege(body.gehege_name, body.imageBase64String)];
                    case 1:
                        if (_a.sent()) {
                            res.json({
                                state: successString,
                                error: null
                            });
                        }
                        else {
                            res.json({
                                state: failureString,
                                error: "On error occured while creating the Gehege"
                            });
                        }
                        return [2 /*return*/];
                    case 2:
                        res.json({
                            state: failureString,
                            error: "User does not have the required privileges"
                        });
                        return [2 /*return*/];
                }
            });
        }); });
        return [2 /*return*/];
    });
}); });
app.get("/getuserinfo", function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var username, token;
    return __generator(this, function (_a) {
        username = req.cookies.username;
        token = req.cookies.token || null;
        authRequest(username, token, function (e, user) {
            if (e != undefined || user == null) {
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
            });
            return;
        });
        return [2 /*return*/];
    });
}); });
app.post("/changeuserinfo", function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var body, username, token, hash;
    return __generator(this, function (_a) {
        body = req.body;
        username = req.cookies.username;
        token = req.cookies.token || null;
        hash = crypto.createHash(hashAlgorithm);
        authRequest(username, token, function (e, user) {
            if (e != undefined || user == null) {
                res.json({
                    state: failureString,
                    error: e
                });
                return;
            }
            hash.update(body.password + salt);
            collection_users.updateOne({ username: username }, {
                $set: {
                    username: body.username !== undefined ? body.username : user.username,
                    description: body.description !== undefined ? body.description : user.description,
                    password: body.password !== undefined ? hash.digest('hex') : user.password
                }
            });
            res.json({
                state: successString,
                error: null
            });
            return;
        });
        return [2 /*return*/];
    });
}); });
app.post("/signup", function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var body;
    return __generator(this, function (_a) {
        body = req.body;
        res.json(createuser(body.username, body.description, body.password, 50, false));
        return [2 /*return*/];
    });
}); });
app.post("/createtok", function (req, res) { return __awaiter(void 0, void 0, void 0, function () {
    var body, users, user, hash;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                body = req.body;
                return [4 /*yield*/, collection_users.find({ username: body.username }).toArray()];
            case 1:
                users = _a.sent();
                if (users.length == 0) {
                    res.json({
                        state: failureString,
                        tok: null,
                        error: "User does not exist"
                    });
                    return [2 /*return*/];
                }
                user = users[0];
                hash = crypto.createHash(hashAlgorithm);
                hash.update(body.password + salt);
                if (user.password == hash.digest('hex')) {
                    //Create temporary token
                    res.cookie("token", setToken(7, user._id));
                    res.cookie("username", user.username);
                    res.json({
                        state: successString,
                        error: null
                    });
                }
                else {
                    res.json({
                        state: failureString,
                        error: "wrong password"
                    });
                }
                return [2 /*return*/];
        }
    });
}); });
function createuser(username, description, password, cash, administrator) {
    return __awaiter(this, void 0, void 0, function () {
        var hash, hashed_password, user, usersWithSameUsername, insertion;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    hash = crypto.createHash(hashAlgorithm);
                    hash.update(password + salt);
                    hashed_password = hash.digest('hex');
                    user = {
                        username: username,
                        password: hashed_password,
                        description: description,
                        cash: cash,
                        administrator: administrator
                    };
                    return [4 /*yield*/, collection_users.find({ username: username }).toArray()];
                case 1:
                    usersWithSameUsername = _a.sent();
                    if (usersWithSameUsername.length > 0) {
                        return [2 /*return*/, {
                                state: failureString,
                                error: "User already exists"
                            }];
                    }
                    return [4 /*yield*/, collection_users.insertOne(user)];
                case 2:
                    insertion = _a.sent();
                    if (insertion.acknowledged) {
                        return [2 /*return*/, {
                                state: successString,
                                error: null
                            }];
                    }
                    return [2 /*return*/, {
                            state: failureString,
                            error: "An unknown error occured"
                        }];
            }
        });
    });
}
function creategehege(name, imageBase64String) {
    return __awaiter(this, void 0, void 0, function () {
        var gehege, insertion;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    gehege = {
                        name: name,
                        image: imageBase64String,
                        donations: 0
                    };
                    return [4 /*yield*/, collection_gehege.insertOne(gehege)];
                case 1:
                    insertion = _a.sent();
                    if (insertion.acknowledged) {
                        return [2 /*return*/, true];
                    }
                    return [2 /*return*/, false];
            }
        });
    });
}
function setToken(daysTilExpire, userid) {
    try {
        var currentTime = Date.now();
        var expirationTime = new Date(currentTime);
        expirationTime.setDate(expirationTime.getDate() + daysTilExpire);
        var token = crypto.randomBytes(16).toString('hex');
        collection_users.updateOne({ _id: userid }, {
            $set: {
                token: token,
                expirationDate: expirationTime
            }
        });
        return token;
    }
    catch (error) {
        return error;
    }
}
function authRequest(username, token, callback) {
    return __awaiter(this, void 0, void 0, function () {
        var users, e_1;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    _a.trys.push([0, 3, , 4]);
                    return [4 /*yield*/, collection_users.find({
                            username: username
                        }).toArray()];
                case 1:
                    users = _a.sent();
                    return [4 /*yield*/, checkToken(users[0]._id, token)];
                case 2:
                    if (_a.sent()) {
                        callback(undefined, users[0]);
                    }
                    else {
                        callback(undefined, null);
                    }
                    return [3 /*break*/, 4];
                case 3:
                    e_1 = _a.sent();
                    callback(e_1, null);
                    return [3 /*break*/, 4];
                case 4: return [2 /*return*/];
            }
        });
    });
}
function checkToken(userid, token) {
    return __awaiter(this, void 0, void 0, function () {
        var users;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, collection_users.find({ _id: userid }).toArray()];
                case 1:
                    users = _a.sent();
                    return [4 /*yield*/, checkTokenExpirationTime(users[0]._id)];
                case 2:
                    if (_a.sent()) {
                        if (users[0].token == token) {
                            return [2 /*return*/, true];
                        }
                        else {
                            return [2 /*return*/, false];
                        }
                    }
                    else {
                        return [2 /*return*/, false];
                    }
                    return [2 /*return*/];
            }
        });
    });
}
function checkTokenExpirationTime(userid) {
    return __awaiter(this, void 0, void 0, function () {
        var users, currentTime, expirationTime;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0: return [4 /*yield*/, collection_users.find({ _id: userid }).toArray()];
                case 1:
                    users = _a.sent();
                    currentTime = new Date(Date.now());
                    expirationTime = new Date(users[0].expirationDate);
                    if (currentTime > expirationTime) {
                        collection_users.updateOne({ _id: userid }, {
                            $unset: {
                                token: "",
                                expirationTime: ""
                            }
                        });
                        return [2 /*return*/, false];
                    }
                    return [2 /*return*/, true];
            }
        });
    });
}
//# sourceMappingURL=index.js.map