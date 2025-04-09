const gren = require("../dist/app.js");
const db = require("./db.js");

async function main() {
  await db.init();
  const app = gren.Gren.Main.init({});
}

main();
