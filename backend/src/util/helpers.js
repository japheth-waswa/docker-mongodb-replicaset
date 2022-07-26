import { createReadStream } from "node:fs";
import * as readline from "node:readline";

export const MONGO_SECRETS_LOCATION = process.env.MONGO_SECRETS_LOCATION;

export const loadMongoSecrets = async () => {
  try {
    const lr = readline.createInterface({
      input: createReadStream(MONGO_SECRETS_LOCATION),
      terminal: false,
    });

    let mongoSecrets = {};
    for await (const line of lr) {
      //skip empty strings & comments
      if (line.trim().length === 0 || line.startsWith("#")) continue;
      const [key, value] = line.split("=");
      mongoSecrets = { ...mongoSecrets, [key]: value };
    }
    return mongoSecrets;
  } catch (e) {
    console.log(e);
    return {};
  }
};
