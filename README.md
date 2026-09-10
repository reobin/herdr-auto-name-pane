# herdr-auto-name-pane

Labels every herdr pane with a short, memorable name (`neon`, `mars`, `lima`), so you and your agent can refer to panes by name instead of ID.

## Install

```sh
herdr plugin install reobin/herdr-auto-name-pane
herdr plugin action invoke reobin.auto-name-pane.install-skill
```

The second command installs the `herdr-auto-name-pane` skill (`SKILL.md` plus `resolve.sh`) into this machine's agent skill directories, for Claude and `~/.agents`-style harnesses. Check it landed with `herdr plugin log list --plugin reobin.auto-name-pane`.

## Use

You never type pane IDs. Say the label:

* to an agent: `check output of pane bison`, `tell the agent in lima pane to rerun the scan`.
* the agent resolves it first (`resolve.sh <label>`, or the inline `herdr api snapshot` filter in the skill), then runs `herdr pane read <id>` or `herdr agent prompt <id>`.

Resolve one by hand:

```sh
sh scripts/resolve.sh bison
```

A pane ID passes through unchanged when it is already in the snapshot. A label duplicated across workspaces exits 2 and lists the candidates rather than guessing.

## Rules

* Existing labels are never overwritten.
* Names are unique across the server.
* When the word list runs out, names gain a numeric suffix (`neon-2`).
* Labels and agent names are independent. A pane labeled `pika` can host an agent named `reviewer`.
