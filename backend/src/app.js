
import path from "path";
import mongoose from "mongoose";
import express from "express";
import { fileURLToPath } from "url";
import { loadMongoSecrets } from "./util/helpers.js"; 
import HttpError from "./util/http-error.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**mongodb setup & connection */
const mongodbConnect = async () => {
  try {
    const {MONGO_HOST_PRIMARY,MONGO_PORT_PRIMARY,MONGODB_APP_DATABASE,MONGODB_NORMAL_USER_USERNAME,MONGODB_NORMAL_USER_PASSWORD} = await loadMongoSecrets();    
    const connStr = `mongodb://${MONGODB_NORMAL_USER_USERNAME}:${MONGODB_NORMAL_USER_PASSWORD}@${MONGO_HOST_PRIMARY}:${MONGO_PORT_PRIMARY}/${MONGODB_APP_DATABASE}?directConnection=true`;
    return await mongoose.connect(connStr);
  } catch (e) {
    console.log(e);
    return false;
  }
};

const mongooseConn = await mongodbConnect();
if (!mongooseConn) {
  process.exit();
}

/**express setup */
const app = express();
const appHost = "http://localhost";
const appPort = 3999;

app.use(express.static(path.join(__dirname, "public")));

app.get("/api/v1/users", (req, res) =>
  res.json([
    { id: "1", names: "jenny" },
    { id: "2", names: "pete" },
    { id: "3", names: "johndoe" },
    { id: "4", names: "peter pan" },
  ])
);

// catch 404 and handle
app.use((req, res, next) => {
  throw new HttpError("Route not found", 404);
});

app.use((error, req, res, next) =>
  res
    .status(error.code || 500)
    .json({ message: error.message || "An unknow error occured!" })
);

const serverApp = app.listen(appPort);
if (serverApp)
  console.log(
    "\x1b[35m%s\x1b[0m",
    `Server running on port ${appHost}:${appPort}`
  );
