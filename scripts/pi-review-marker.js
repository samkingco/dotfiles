#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const filePath = process.argv[2] || process.env.ZED_FILE;
const rowInput = process.argv[3] || process.env.ZED_ROW;
const selectedTextInput = process.argv[4] ?? process.env.ZED_SELECTED_TEXT ?? "";
const selectedText = selectedTextInput === "__PI_REVIEW_NO_SELECTION__" ? "" : selectedTextInput;
const worktreeRoot = process.argv[5] || process.env.ZED_WORKTREE_ROOT || process.cwd();

if (!filePath) {
	fail("ZED_FILE was not provided.");
}

if (!fs.existsSync(filePath)) {
	fail(`File does not exist: ${filePath}`);
}

const content = fs.readFileSync(filePath, "utf8");
const eol = content.includes("\r\n") ? "\r\n" : "\n";
const lines = content.split(/\r?\n/u);
const hadFinalNewline = content.endsWith("\n");
if (hadFinalNewline) lines.pop();

const id = `pir-${Date.now()}`;
const instruction = "<instruction>";
const row = Number.parseInt(rowInput ?? "0", 10);
const fallbackLineIndex = clamp(Number.isFinite(row) ? row : 0, 0, Math.max(lines.length - 1, 0));

const selectedRange = findSelectedLineRange(content, selectedText, row);

if (selectedRange) {
	const comment = commentStyleFor(filePath, lines, selectedRange.startLineIndex);
	wrapLines(lines, selectedRange.startLineIndex, selectedRange.endLineIndex, id, instruction, comment);
	writeLines(filePath, lines, eol, hadFinalNewline);
	console.log(`Inserted PI-REVIEW block ${id} around selected text in ${relativePath(filePath, worktreeRoot)}.`);
	process.exit(0);
}

const comment = commentStyleFor(filePath, lines, fallbackLineIndex);
wrapLines(lines, fallbackLineIndex, fallbackLineIndex, id, instruction, comment);
writeLines(filePath, lines, eol, hadFinalNewline);
console.log(`Inserted PI-REVIEW block ${id} around current line in ${relativePath(filePath, worktreeRoot)}.`);

function findSelectedLineRange(fileContent, selection, zedRow) {
	const normalizedSelection = normalizeNewlines(selection);
	if (!normalizedSelection.trim()) return undefined;

	const normalizedContent = normalizeNewlines(fileContent);
	const occurrences = [];
	let searchFrom = 0;

	while (searchFrom <= normalizedContent.length) {
		const index = normalizedContent.indexOf(normalizedSelection, searchFrom);
		if (index === -1) break;
		occurrences.push(index);
		searchFrom = index + Math.max(normalizedSelection.length, 1);
	}

	if (occurrences.length === 0) return undefined;

	const starts = lineStarts(normalizedContent);
	const targetRows = Number.isFinite(zedRow) ? [zedRow, zedRow + 1] : [0];
	let best;

	for (const index of occurrences) {
		const startLineIndex = lineIndexAt(starts, index);
		let endOffset = normalizedSelection.length - 1;
		while (endOffset > 0 && normalizedSelection[endOffset] === "\n") endOffset -= 1;
		const endLineIndex = lineIndexAt(starts, index + endOffset);
		const oneBasedStartLine = startLineIndex + 1;
		const distance = Math.min(...targetRows.map((target) => Math.abs(oneBasedStartLine - target)));

		if (!best || distance < best.distance) {
			best = {startLineIndex, endLineIndex, distance};
		}
	}

	return best;
}

function lineStarts(text) {
	const starts = [0];
	for (let index = 0; index < text.length; index += 1) {
		if (text[index] === "\n") starts.push(index + 1);
	}
	return starts;
}

function lineIndexAt(starts, charIndex) {
	let low = 0;
	let high = starts.length - 1;

	while (low <= high) {
		const mid = Math.floor((low + high) / 2);
		if (starts[mid] <= charIndex) low = mid + 1;
		else high = mid - 1;
	}

	return Math.max(0, high);
}

function wrapLines(targetLines, startLineIndex, endLineIndex, markerId, markerInstruction, markerComment) {
	const indent = leadingWhitespace(targetLines[startLineIndex] ?? "");
	const startMarker = formatMarker(markerComment, `PI-REVIEW-START id=${markerId}: ${markerInstruction}`, indent);
	const endMarker = formatMarker(markerComment, `PI-REVIEW-END id=${markerId}`, indent);
	targetLines.splice(startLineIndex, 0, startMarker);
	targetLines.splice(endLineIndex + 2, 0, endMarker);
}

function formatMarker(comment, text, indent) {
	if (comment.suffix) return `${indent}${comment.prefix} ${text} ${comment.suffix}`;
	return `${indent}${comment.prefix} ${text}`;
}

function commentStyleFor(targetPath, targetLines, startLineIndex) {
	const extension = path.extname(targetPath).toLowerCase();
	const basename = path.basename(targetPath).toLowerCase();

	if ([".tsx", ".jsx"].includes(extension) && looksLikeJsxLine(targetLines[startLineIndex] ?? "")) {
		return {prefix: "{/*", suffix: "*/}"};
	}

	if ([".css", ".scss", ".sass"].includes(extension)) return {prefix: "/*", suffix: "*/"};
	if ([".html", ".htm", ".md", ".mdx", ".xml", ".svg"].includes(extension)) return {prefix: "<!--", suffix: "-->"};
	if ([".sql"].includes(extension)) return {prefix: "--"};
	if ([".py", ".sh", ".bash", ".zsh", ".fish", ".rb", ".yml", ".yaml", ".toml"].includes(extension)) return {prefix: "#"};
	if ([".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".jsonc"].includes(extension)) return {prefix: "//"};
	if (["makefile", "dockerfile"].includes(basename)) return {prefix: "#"};

	return {prefix: "//"};
}

function looksLikeJsxLine(line) {
	const trimmed = line.trimStart();
	return /^<\/?[A-Za-z]/u.test(trimmed) || /^<>/u.test(trimmed);
}

function writeLines(targetPath, targetLines, targetEol, finalNewline) {
	const nextContent = targetLines.join(targetEol) + (finalNewline ? targetEol : "");
	fs.writeFileSync(targetPath, nextContent, "utf8");
}

function leadingWhitespace(line) {
	return line.match(/^\s*/u)?.[0] ?? "";
}

function normalizeNewlines(text) {
	return text.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
}

function clamp(value, min, max) {
	return Math.min(Math.max(value, min), max);
}

function relativePath(targetPath, root) {
	const relative = path.relative(root, targetPath);
	return relative && !relative.startsWith("..") ? relative : targetPath;
}

function fail(message) {
	console.error(message);
	process.exit(1);
}
