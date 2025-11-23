import assert from "assert";
import http from "http";
import { AddressInfo } from "net";
import { fetch } from "undici";
import { createBlobApp, setBlobForTest } from "../src/blobService";
import { decideOnPost, processPost } from "../src/worker";

async function postBlob(baseUrl: string, data: Buffer): Promise<string> {
    const res = await fetch(`${baseUrl}/blob`, { method: "POST", body: data, headers: { "content-type": "application/octet-stream" } });
    const json = (await res.json()) as { cidHash: string };
    return json.cidHash;
}

async function main() {
    const app = createBlobApp();
    const server = app.listen(0);
    const addr = server.address() as AddressInfo;
    const baseUrl = `http://127.0.0.1:${addr.port}`;

    try {
        const cidHash = await postBlob(baseUrl, Buffer.from("hello"));
        const ok = await processPost({ postId: "0x1", cidHash, kzgCommit: "0x0" }, baseUrl);
        assert.strictEqual(ok, "ok");
        const decisionOk = await decideOnPost({ postId: "0x1", cidHash, kzgCommit: "0x0" }, baseUrl);
        assert.strictEqual(decisionOk.decision, "yes");

        setBlobForTest(cidHash, Buffer.from("tampered"));
        const mismatch = await processPost({ postId: "0x1", cidHash, kzgCommit: "0x0" }, baseUrl);
        assert.strictEqual(mismatch, "mismatch");

        const missing = await processPost({ postId: "0x2", cidHash: "0xbeef", kzgCommit: "0x0" }, baseUrl);
        assert.strictEqual(missing, "missing");
        const decisionMissing = await decideOnPost({ postId: "0x2", cidHash: "0xbeef", kzgCommit: "0x0" }, baseUrl);
        assert.strictEqual(decisionMissing.decision, "no");

        console.log("worker tests passed");
    } catch (err) {
        console.error(err);
        process.exitCode = 1;
    } finally {
        await new Promise((res) => server.close(() => res(null)));
    }
}

if (require.main === module) void main();
