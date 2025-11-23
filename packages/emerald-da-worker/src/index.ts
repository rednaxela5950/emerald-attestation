import { createBlobApp } from "./blobService";

export function main() {
  const app = createBlobApp();
  const port = Number(process.env.PORT || 4000);
  app.listen(port, () => console.log(`blob service listening on :${port}`));
}

if (require.main === module) {
  main();
}
