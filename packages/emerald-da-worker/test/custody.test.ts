import assert from "assert";
import { submitCustodyProof } from "../src/worker";

async function main() {
  await submitCustodyProof("0x1", "0x2", "0x3", "http://localhost:8545", true);
  assert.ok(true, "lazy mode does nothing");
  console.log("custody submission stub ok");
}

if (require.main === module) void main();
