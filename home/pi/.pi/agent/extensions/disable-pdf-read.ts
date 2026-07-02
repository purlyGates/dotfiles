/**
 * disable-pdf-read: removes built-in `pdf_read` tool from active set.
 * markitdown extension covers PDF -> Markdown instead.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DISABLED = ["pdf_read"];

export default function (pi: ExtensionAPI) {
	const apply = () => {
		const active = pi.getActiveTools().filter((t) => !DISABLED.includes(t));
		pi.setActiveTools(active);
	};
	pi.on("session_start", async () => apply());
	pi.on("session_tree", async () => apply());
}
