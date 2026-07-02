/**
 * Show provider in status bar when switching model.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("model_select", async (event, ctx) => {
    ctx.ui.setStatus("provider", ctx.ui.theme.fg("muted", `[${event.model.provider}]`));
  });
}
