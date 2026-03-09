/**
 * Simple Footer Extension
 *
 * Shows: cwd (branch) • ↑input ↓output $cost context% provider/model • thinking
 */

import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

export default function (pi: ExtensionAPI) {
	let enabled = false;

	const createFooter = (ctx: any) => (tui: any, theme: any, footerData: any) => {
		const unsub = footerData.onBranchChange(() => tui.requestRender());

		return {
			dispose: unsub,
			invalidate() {},
			render(width: number): string[] {
				// Compute tokens
				let input = 0,
					output = 0,
					cost = 0;
				let thinkingLevel = "off";

				for (const e of ctx.sessionManager.getEntries()) {
					if (e.type === "message" && e.message.role === "assistant") {
						const m = e.message as AssistantMessage;
						input += m.usage.input;
						output += m.usage.output;
						cost += m.usage.cost.total;
					} else if (e.type === "thinking_level_change") {
						// @ts-ignore
						thinkingLevel = e.thinkingLevel;
					}
				}

				// CWD with ~
				let cwd = ctx.sessionManager.getCwd();
				const home = process.env.HOME || process.env.USERPROFILE;
				if (home && cwd.startsWith(home)) {
					cwd = `~${cwd.slice(home.length)}`;
				}

				// Add branch
				const branch = footerData.getGitBranch();
				if (branch) cwd = `${cwd} ${branch}`;

				// Context usage
				const contextUsage = ctx.getContextUsage?.();
				const contextWindow =
					contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
				const contextPercentValue = contextUsage?.percent ?? 0;
				const contextPercent =
					contextUsage?.percent != null
						? `${contextPercentValue.toFixed(1)}%/${formatTokens(contextWindow)}`
						: `?/${formatTokens(contextWindow)}`;

				// Stats with color for context
				let contextStr: string;
				if (contextPercentValue > 90)
					contextStr = theme.fg("error", contextPercent);
				else if (contextPercentValue > 70)
					contextStr = theme.fg("warning", contextPercent);
				else contextStr = contextPercent;

				const stats = [
					`↑${formatTokens(input)}`,
					`↓${formatTokens(output)}`,
					`$${cost.toFixed(3)}`,
					contextStr,
				].join(" ");

				// Left side: cwd • stats
				const leftText = `${cwd} • ${stats}`;
				const leftWidth = visibleWidth(leftText);

				// Right side: provider/model • thinking
				const modelName = ctx.model?.id || "no-model";
				const provider = ctx.model?.provider || "";
				let rightSide = provider ? `${provider}/${modelName}` : modelName;

				if (ctx.model?.reasoning) {
					rightSide =
						thinkingLevel === "off"
							? `${rightSide} • thinking off`
							: `${rightSide} • ${thinkingLevel}`;
				}

				// Layout with padding
				const rightWidth = visibleWidth(rightSide);
				const minPadding = 2;
				const totalNeeded = leftWidth + minPadding + rightWidth;

				let line: string;
				if (totalNeeded <= width) {
					const padding = " ".repeat(width - leftWidth - rightWidth);
					line = leftText + padding + rightSide;
				} else {
					const avail = width - leftWidth - minPadding;
					if (avail > 0) {
						const truncated = truncateToWidth(rightSide, avail, "");
						const pad = " ".repeat(
							Math.max(0, width - leftWidth - visibleWidth(truncated)),
						);
						line = leftText + pad + truncated;
					} else {
						line = truncateToWidth(leftText, width, "...");
					}
				}

				return [theme.fg("dim", truncateToWidth(line, width))];
			},
		};
	};

	pi.registerCommand("simple-footer", {
		description: "Toggle simple footer",
		handler: async (_args, ctx) => {
			enabled = !enabled;

			if (enabled) {
				ctx.ui.setFooter(createFooter(ctx));
				ctx.ui.notify("Simple footer enabled", "info");
			} else {
				ctx.ui.setFooter(undefined);
				ctx.ui.notify("Default footer restored", "info");
			}
		},
	});

	pi.on("session_start", (_event, ctx) => {
		enabled = true;
		ctx.ui.setFooter(createFooter(ctx));
	});
}
