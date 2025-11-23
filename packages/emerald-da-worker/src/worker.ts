import crypto from "crypto";
import { fetch } from "undici";

export type PostInput = { postId: string; cidHash: string; kzgCommit: string };
export type ProcessResult = "ok" | "missing" | "mismatch";
export type Decision = { decision: "yes" | "no"; reason: ProcessResult };

export async function processPost(post: PostInput, baseUrl: string): Promise<ProcessResult> {
    const res = await fetch(`${baseUrl}/blob/${post.cidHash}`);
    if (res.status === 404) return "missing";
    if (!res.ok) throw new Error(`blob fetch failed: ${res.status}`);

    const body = Buffer.from(await res.arrayBuffer());
    const digest = "0x" + crypto.createHash("sha3-256").update(body).digest("hex");
    return digest.toLowerCase() === post.cidHash.toLowerCase() ? "ok" : "mismatch";
}

export async function decideOnPost(post: PostInput, baseUrl: string): Promise<Decision> {
    const result = await processPost(post, baseUrl);
    if (result === "ok") return { decision: "yes", reason: result };
    return { decision: "no", reason: result };
}
