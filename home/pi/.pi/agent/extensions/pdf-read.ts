/**
 * PDF Read Tool - extract text from PDF via pdftotext
 */

import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { resolve } from "node:path";
import { Type } from "@earendil-works/pi-ai";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const execFileP = promisify(execFile);

const pdfReadTool = defineTool({
	name: "pdf_read",
	label: "PDF Read",
	description:
		"Extract text from a PDF file using pdftotext. Supports page range and layout preservation.",
	parameters: Type.Object({
		path: Type.String({ description: "Path to PDF file (absolute or relative to cwd)" }),
		first_page: Type.Optional(Type.Number({ description: "First page to extract (1-indexed)" })),
		last_page: Type.Optional(Type.Number({ description: "Last page to extract (inclusive)" })),
		layout: Type.Optional(
			Type.Boolean({ description: "Preserve original layout (default false)" }),
		),
	}),

	async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
		const absPath = resolve(params.path);
		const args: string[] = [];
		if (params.first_page !== undefined) args.push("-f", String(params.first_page));
		if (params.last_page !== undefined) args.push("-l", String(params.last_page));
		if (params.layout) args.push("-layout");
		args.push(absPath, "-");

		try {
			const { stdout } = await execFileP("pdftotext", args, {
				signal,
				maxBuffer: 50 * 1024 * 1024,
			});
			return {
				content: [{ type: "text", text: stdout || "(no text extracted)" }],
				details: { path: absPath, bytes: stdout.length },
			};
		} catch (err: unknown) {
			const msg = err instanceof Error ? err.message : String(err);
			return {
				content: [{ type: "text", text: `pdftotext failed: ${msg}` }],
				isError: true,
			};
		}
	},
});

export default function (pi: ExtensionAPI) {
	pi.registerTool(pdfReadTool);
}
