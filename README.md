# herdr-auto-name-pane

Labels every herdr pane with a short, memorable name (`neon`, `mars`, `lima`), so you and your agent can easily refer to panes by name instead of ID.

## Install

```sh
herdr plugin install reobin/herdr-auto-name-pane
herdr plugin action invoke reobin.auto-name-pane.install-skill
```

The second command copies `SKILL.md` into this machine's agent skill directories (Claude and `~/.agents`-style harnesses). Check it landed with `herdr plugin log list --plugin reobin.auto-name-pane`.

## Use

You never type pane IDs. Say the label:

- to an agent: `check output of pane bison`, `tell the agent in lima pane to rerun the scan`.
- the agent resolves it first (`herdr api snapshot` label to pane ID filter from the skill), then runs `herdr pane read <id>` or `herdr agent prompt <id>`.

Rules: existing labels are never overwritten. Names are unique across the server. When the list runs out, names gain a numeric suffix (`neon-2`).
