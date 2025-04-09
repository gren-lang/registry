const process = require("process");
const sqlite3 = require("sqlite3");

// Uncomment if debugging
// (performance hit in prod)
//sqlite3.verbose();

const dbPath = process.env["DATABASE_URL"] || ":memory:";

const migrations = [
  `PRAGMA foreign_keys = ON`,
  `CREATE TABLE IF NOT EXISTS user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE
  ) STRICT`,
  `CREATE TABLE IF NOT EXISTS session (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created INTEGER NOT NULL,
    user_id INTEGER NOT NULL REFERENCES user(id),
    nonce TEXT NOT NULL UNIQUE,
    validation_token TEXT NOT NULL UNIQUE,
    validation_code TEXT UNIQUE, -- null until user visits link with validation token
    session_token TEXT UNIQUE -- null until cli posts with nonce and validation code
  ) STRICT`,
  `CREATE TABLE IF NOT EXISTS publishing_identity (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
  ) STRICT`,
  `CREATE TABLE IF NOT EXISTS role (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
  ) STRICT`,
  `CREATE TABLE IF NOT EXISTS publishing_identity_users (
    user_id INTEGER NOT NULL REFERENCES user(id),
    publishing_identity_id INTEGER NOT NULL REFERENCES publishing_identity(id),
    role_id INTEGER NOT NULL REFERENCES role(id)
  ) STRICT`,
];

const db = new sqlite3.Database(dbPath, (err) => {
  if (err != null) {
    console.error(`Failed to open database ${dbPath} with error: ${err}`);
    process.exit(1);
  }
  console.log(`Opened database ${dbPath}`);
});

async function init() {
  try {
    for (let migration of migrations) {
      await run(migration);
    }
  } catch (err) {
    console.error(`Failed to initialize database ${dbPath} with error ${err}`);
    process.exit(1);
  }
}

function run(stmt, params) {
  return new Promise((resolve, reject) => {
    db.run(stmt, params, function (err) {
      if (err != null) {
        reject(err);
      } else {
        resolve(this.changes);
      }
    });
  });
}

function query(stmt, params) {
  return new Promise((resolve, reject) => {
    db.all(stmt, params, (err, rows) => {
      if (err != null) {
        reject(err);
      } else {
        resolve(rows);
      }
    });
  });
}

function queryOne(stmt, params) {
  return new Promise((resolve, reject) => {
    db.get(stmt, params, (err, row) => {
      if (err != null) {
        reject(err);
      } else {
        resolve(row);
      }
    });
  });
}

function close(cb) {
  db.close(cb);
}

module.exports = {
  init,
  run,
  query,
  queryOne,
  close,
};
