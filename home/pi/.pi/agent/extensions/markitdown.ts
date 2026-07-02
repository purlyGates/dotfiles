/**
 * markitdown extension
 *
 * Registers a `markitdown` tool that converts docs (pdf, docx, pptx, xlsx,
 * html, images, audio, etc.) to Markdown via Microsoft's markitdown CLI.
 *
 * Requires: `pipx install 'markitdown[all]'` (or `pip install markitdown[all]`)
 * https://github.com/microsoft/markitdown
 */

import { execFile } from "node:child_process";
import { mkdir, writeFile } from "node:fs/promises";
import { dirname, isAbsolute, resolve } from "node:path";
import { promisify } from "node:util";

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const execFileP = promisify(execFile);

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "markitdown",
		label: "MarkItDown",
		description:
			"Convert a file (PDF, DOCX, PPTX, XLSX, HTML, image, audio, zip, etc.) to Markdown using Microsoft markitdown. Returns markdown text; optionally writes to outputPath.",
		parameters: Type.Object({
			input: Type.String({
				description: "Path to input file (absolute or relative to cwd).",
			}),
			outputPath: Type.Optional(
				Type.String({
					description:
						"Optional path to write the resulting markdown. If omitted, markdown is only returned in the tool result.",
				}),
			),
			maxChars: Type.Optional(
				Type.Number({
					description:
						"Truncate returned markdown to this many characters (default 200000). Full content still written to outputPath if set.",
				}),
			),
		}),
		async execute(_id, params, signal, _onUpdate, ctx) {
			const cwd = ctx.cwd ?? process.cwd();
			const inputAbs = isAbsolute(params.input) ? params.input : resolve(cwd, params.input);

			let stdout: string;
			try {
				const res = await execFileP("markitdown", [inputAbs], {
					signal,
					maxBuffer: 256 * 1024 * 1024,
					encoding: "utf8",
				});
				stdout = res.stdout;
			} catch (err: unknown) {
				const e = err as { code?: string; stderr?: string; message?: string };
				const hint =
					e.code === "ENOENT"
						? "\n\nmarkitdown CLI not found. Install with: pipx install 'markitdown[all]'"
						: "";
				return {
					content: [
						{
							type: "text",
							text: `markitdown failed: ${e.stderr || e.message || String(err)}${hint}`,
						},
					],
					details: { error: true },
					isError: true,
				};
			}

			let wrotePath: string | undefined;
			if (params.outputPath) {
				const outAbs = isAbsolute(params.outputPath)
					? params.outputPath
					: resolve(cwd, params.outputPath);
				await mkdir(dirname(outAbs), { recursive: true });
				await writeFile(outAbs, stdout, "utf8");
				wrotePath = outAbs;
			}

			const max = params.maxChars ?? 200_000;
			const truncated = stdout.length > max;
			const body = truncated ? `${stdout.slice(0, max)}\n\n…[truncated ${stdout.length - max} chars]` : stdout;

			const header = wrotePath
				? `Converted ${inputAbs} -> ${wrotePath} (${stdout.length} chars)\n\n`
				: `Converted ${inputAbs} (${stdout.length} chars)\n\n`;

			return {
				content: [{ type: "text", text: header + body }],
				details: {
					input: inputAbs,
					outputPath: wrotePath,
					bytes: stdout.length,
					truncated,
				},
			};
		},
	});
}
