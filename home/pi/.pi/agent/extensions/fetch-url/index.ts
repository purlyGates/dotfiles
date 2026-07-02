/**
 * fetch-url - Fetch page contents using a headless browser (Playwright).
 *
 * Renders JS-heavy pages and returns text or HTML.
 *
 * Setup:
 *   cd ~/.pi/agent/extensions/fetch-url && npm install
 *   npx playwright install chromium
 */

import { Type, StringEnum } from "@earendil-works/pi-ai";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { Browser } from "playwright";

let browserPromise: Promise<Browser> | null = null;

async function getBrowser(): Promise<Browser> {
	if (!browserPromise) {
		const { chromium } = await import("playwright");
		browserPromise = chromium.launch({ headless: true });
	}
	return browserPromise;
}

const MAX_OUTPUT = 200_000;

const fetchUrlTool = defineTool({
	name: "fetch_url",
	label: "Fetch URL",
	description:
		"Fetch contents of a URL using a headless browser (Playwright Chromium). " +
		"Runs JavaScript and returns rendered text or HTML. Use for pages that need JS rendering " +
		"or when a plain HTTP fetch is insufficient.",
	parameters: Type.Object({
		url: Type.String({ description: "URL to fetch (must include scheme, e.g. https://)" }),
		format: Type.Optional(
			StringEnum(["text", "html"], {
				description: "Return rendered visible text (default) or full HTML",
			}),
		),
		wait_until: Type.Optional(
			StringEnum(["load", "domcontentloaded", "networkidle", "commit"], {
				description: "Playwright wait condition. Default: networkidle",
			}),
		),
		timeout_ms: Type.Optional(
			Type.Integer({
				minimum: 1000,
				maximum: 120_000,
				description: "Navigation timeout in ms. Default: 30000",
			}),
		),
		selector: Type.Optional(
			Type.String({
				description: "Optional CSS selector to extract only that element's content",
			}),
		),
	}),

	async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
		const format = params.format ?? "text";
		const waitUntil = params.wait_until ?? "networkidle";
		const timeout = params.timeout_ms ?? 30_000;

		const browser = await getBrowser();
		const context = await browser.newContext({
			userAgent:
				"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36",
		});
		const page = await context.newPage();

		const onAbort = () => {
			page.close().catch(() => {});
			context.close().catch(() => {});
		};
		signal?.addEventListener("abort", onAbort, { once: true });

		try {
			const response = await page.goto(params.url, { waitUntil, timeout });
			const status = response?.status() ?? 0;
			const finalUrl = page.url();

			let body: string;
			if (params.selector) {
				const el = await page.$(params.selector);
				if (!el) {
					return {
						content: [
							{
								type: "text" as const,
								text: `Selector not found: ${params.selector}\nURL: ${finalUrl} (HTTP ${status})`,
							},
						],
						details: { url: finalUrl, status, selector: params.selector, found: false },
					};
				}
				body =
					format === "html"
						? ((await el.evaluate((n: Element) => (n as HTMLElement).outerHTML)) as string)
						: (((await el.innerText()) as string) ?? "");
			} else if (format === "html") {
				body = await page.content();
			} else {
				body = (await page.evaluate(() => document.body?.innerText ?? "")) as string;
			}

			const title = await page.title().catch(() => "");
			let truncated = false;
			if (body.length > MAX_OUTPUT) {
				body = body.slice(0, MAX_OUTPUT);
				truncated = true;
			}

			const header =
				`URL: ${finalUrl}\nHTTP ${status}\nTitle: ${title}\nFormat: ${format}` +
				(truncated ? `\n[truncated to ${MAX_OUTPUT} chars]` : "") +
				"\n\n";

			return {
				content: [{ type: "text" as const, text: header + body }],
				details: {
					url: finalUrl,
					status,
					title,
					format,
					length: body.length,
					truncated,
				},
			};
		} finally {
			signal?.removeEventListener("abort", onAbort);
			await page.close().catch(() => {});
			await context.close().catch(() => {});
		}
	},
});

export default function (pi: ExtensionAPI) {
	pi.registerTool(fetchUrlTool);

	pi.on("session_end" as any, async () => {
		if (browserPromise) {
			try {
				const b = await browserPromise;
				await b.close();
			} catch {}
			browserPromise = null;
		}
	});
}
