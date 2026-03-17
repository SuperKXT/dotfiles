#!/usr/bin/env node

import { execFileSync } from "child_process";
import { existsSync, readdirSync } from "fs";
import { homedir } from "os";
import { join } from "path";
import { createInterface } from "readline";

const SEARCH_DIR = join(homedir(), "repos");

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

function send(msg: PluginResponse): void {
  process.stdout.write(JSON.stringify(msg) + "\n");
}

function findRepos(query: string): string[] {
  if (!existsSync(SEARCH_DIR)) return [];
  const queryLower = query.toLowerCase();
  return readdirSync(SEARCH_DIR, { withFileTypes: true })
    .filter(
      (entry) =>
        entry.isDirectory() &&
        existsSync(join(SEARCH_DIR, entry.name, ".git")) &&
        (!queryLower || entry.name.toLowerCase().startsWith(queryLower)),
    )
    .sort((a, b) => a.name.localeCompare(b.name))
    .map((entry) => entry.name);
}

const icon: Icon = { Name: "com.visualstudio.code" };
let repos: string[] = [];
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
      for (const [id, name] of repos.entries()) {
        send({
          Append: {
            id,
            name,
            description: join(SEARCH_DIR, name),
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
    if (repo) send({ Fill: `code:${repo}` });
  } else if (typeof msg === "object" && "Activate" in msg) {
    const repo = repos[msg.Activate];
    if (repo) execFileSync("code", [join(SEARCH_DIR, repo)]);
  } else if (msg === "Exit") {
    process.exit(0);
  }
});
