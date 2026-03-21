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

function findRepos(query: string): Repo[] {
	const queryLower = query.toLowerCase();
	const matches = (name: string) =>
		!queryLower || name.toLowerCase().startsWith(queryLower);

	const fromReposDir: Repo[] = existsSync(REPOS_DIR)
		? readdirSync(REPOS_DIR, { withFileTypes: true })
				.filter(
					(entry) =>
						entry.isDirectory() &&
						existsSync(join(REPOS_DIR, entry.name, ".git")) &&
						matches(entry.name),
				)
				.sort((a, b) => a.name.localeCompare(b.name))
				.map((entry) => ({
					name: entry.name,
					path: join(REPOS_DIR, entry.name),
				}))
		: [];

	const fromExtra: Repo[] = EXTRA_REPOS.filter(
		(p) => existsSync(join(p, ".git")) && matches(p.split("/").at(-1)!),
	).map((p) => ({ name: p.split("/").at(-1)!, path: p }));

	return [...fromReposDir, ...fromExtra];
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
