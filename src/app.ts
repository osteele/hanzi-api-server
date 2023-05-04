import cors from "cors";
import express, { Application, Request, Response } from "express";
import sqlite3 from "sqlite3";

const corsOrigins = process.env.CORS_ORIGINS;
const databasePath = process.env.DATABASE_PATH || "data/decompositions.sqlite";
const homePageRedirectUrl = process.env.HOME_PAGE_REDIRECT_URL;

const app: Application = express();

if (corsOrigins) {
  const allowedOrigins = corsOrigins
    .split(",")
    // prepend `https://` to any origin that doesn't have a schema
    .map((origin) =>
      origin.match(/^[a-zA-Z]+:\/\//) ? origin : `https://${origin}`
    );

  const corsOptions = {
    origin: (origin: string | undefined, callback: any) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
  };
  app.use(cors(corsOptions));
} else {
  app.use(cors());
}

const db = new sqlite3.Database(databasePath);

app.get("/", (_req: Request, res: Response) => {
  if (homePageRedirectUrl) {
    res.redirect(homePageRedirectUrl);
  } else {
    const { name, description, repository } = require("../package.json");
    res.send(`<h1>${name}</h1>
    <p>${description}</p>
    <a href="${repository.url}">${repository.url}</a>`);
  }
});

app.get("/health", (_req: Request, res: Response) => {
  res.send("OK");
});

app.get("/status", (_req: Request, res: Response) => {
  res.json({
    status: "OK",
    version: require("../package.json").version,
    uptime: process.uptime(),
  });
});

app.get(
  "/character/:character/decomposition",
  (req: Request, res: Response) => {
    const character = req.params.character;
    db.get(
      "SELECT * FROM decompositions WHERE component = ? LIMIT 1",
      [character],
      (err: Error, row: any) => {
        if (err) {
          console.error(err);
          res.status(500).send("Database error");
          return;
        }

        if (!row) {
          res.status(404).send("Character not found");
          return;
        }

        // Create an object with field names and values
        try {
          res.json(row);
        } catch (err) {
          console.error(err);
          res.status(500).send("Server error");
        }
      }
    );
  }
);

export default app;
