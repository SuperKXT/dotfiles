#!/usr/bin/env node

import { execFileSync } from "child_process";
import { existsSync, readdirSync } from "fs";
import { homedir } from "os";
import { join } from "path";
import { createInterface } from "readline";

const REPOS_DIR = join(homedir(), "repos");
const EXTRA_REPOS = [join(homedir(), "dotfiles")];

type Icon = { Name: string };

type PluginResponse =
	| {
			Append: {
				id: number;
				name: string;
				description: string;
				icon: Icon;
				category_icon: Icon;
				window: null;
			};
	  }
	| { Fill: string }
	| "Finished";

type Repo = { name: string; path: string };

function send(msg: PluginResponse): void {
	process.stdout.write(JSON.stringify(msg) + "\n");
}

// Lower score is a better match. Rewards matching more of the query
// consecutively and rewards matches that start earlier in the name.
function subsequenceScore(name: string, queryLower: string): number | null {
	if (!queryLower) return 0;

	const nameLower = name.toLowerCase();
	let score = 0;
	let nameIdx = 0;
	let prevMatchIdx = -1;
	let firstMatchIdx = -1;

	for (const ch of queryLower) {
		const idx = nameLower.indexOf(ch, nameIdx);
		if (idx === -1) return null;

		if (firstMatchIdx === -1) firstMatchIdx = idx;
		score += prevMatchIdx !== -1 && idx === prevMatchIdx + 1 ? 0 : idx;
		prevMatchIdx = idx;
		nameIdx = idx + 1;
	}

	return score + firstMatchIdx;
}

function levenshtein(a: string, b: string): number {
	let prev = Array.from({ length: b.length + 1 }, (_, j) => j);

	for (let i = 1; i <= a.length; i++) {
		const curr = new Array<number>(b.length + 1);
		curr[0] = i;
		for (let j = 1; j <= b.length; j++) {
			curr[j] =
				a[i - 1] === b[j - 1]
					? prev[j - 1]!
					: 1 + Math.min(prev[j - 1]!, prev[j]!, curr[j - 1]!);
		}
		prev = curr;
	}

	return prev[b.length]!;
}

// Catches typos a pure subsequence match can't (e.g. a swapped letter),
// by allowing a small edit distance against similarly-sized windows of name.
function typoScore(name: string, queryLower: string): number | null {
	if (!queryLower) return 0;

	const nameLower = name.toLowerCase();
	const qLen = queryLower.length;
	const threshold = Math.max(1, Math.floor(qLen / 4));

	let best: number | null = null;
	let bestPos = 0;

	for (let len = Math.max(1, qLen - threshold); len <= qLen + threshold; len++) {
		for (let start = 0; start + len <= nameLower.length; start++) {
			const distance = levenshtein(nameLower.slice(start, start + len), queryLower);
			if (best === null || distance < best) {
				best = distance;
				bestPos = start;
			}
		}
	}

	if (best === null || best > threshold) return null;
	return best * 100 + bestPos;
}

function fuzzyScore(name: string, queryLower: string): number | null {
	const scores = [subsequenceScore(name, queryLower), typoScore(name, queryLower)].filter(
		(s): s is number => s !== null,
	);
	return scores.length ? Math.min(...scores) : null;
}

function findRepos(query: string): Repo[] {
	const queryLower = query.toLowerCase();

	const fromReposDir: Repo[] = existsSync(REPOS_DIR)
		? readdirSync(REPOS_DIR, { withFileTypes: true })
				.filter(
					(entry) =>
						entry.isDirectory() &&
						existsSync(join(REPOS_DIR, entry.name, ".git")),
				)
				.map((entry) => ({
					name: entry.name,
					path: join(REPOS_DIR, entry.name),
				}))
		: [];

	const fromExtra: Repo[] = EXTRA_REPOS.filter((p) =>
		existsSync(join(p, ".git")),
	).map((p) => ({ name: p.split("/").at(-1)!, path: p }));

	return [...fromReposDir, ...fromExtra]
		.map((repo) => ({ repo, score: fuzzyScore(repo.name, queryLower) }))
		.filter((entry): entry is { repo: Repo; score: number } => entry.score !== null)
		.sort((a, b) => a.score - b.score || a.repo.name.localeCompare(b.repo.name))
		.map((entry) => entry.repo);
}

const icon: Icon = { Name: "com.visualstudio.code" };
let repos: Repo[] = [];
let showingHint = false;

createInterface({ input: process.stdin }).on("line", (line) => {
	const trimmed = line.trim();
	if (!trimmed) return;

	const msg = JSON.parse(trimmed);

	if (typeof msg === "object" && "Search" in msg) {
		const query = msg.Search.replace(/^code:/, "");
		showingHint = !query;
		if (showingHint) {
			repos = [];
			send({
				Append: {
					id: 0,
					name: "Open Repo in VS Code",
					description: "Type a repo name to search",
					icon,
					category_icon: icon,
					window: null,
				},
			});
		} else {
			repos = findRepos(query);
			for (const [id, { name, path }] of repos.entries()) {
				send({
					Append: {
						id,
						name,
						description: path,
						icon,
						category_icon: icon,
						window: null,
					},
				});
			}
		}
		send("Finished");
	} else if (typeof msg === "object" && "Complete" in msg) {
		const repo = repos[msg.Complete];
		if (repo) send({ Fill: `code:${repo.name}` });
	} else if (typeof msg === "object" && "Activate" in msg) {
		const repo = repos[msg.Activate];
		if (repo) execFileSync("code", [repo.path]);
	} else if (msg === "Exit") {
		process.exit(0);
	}
});
