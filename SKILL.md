---
name: herdr-auto-name-pane
description: Resolve a Herdr pane label (a short name like neon, mars, pluto shown on the pane border) to the pane ID that herdr commands require. Use whenever someone names a pane, terminal, or agent instead of giving an ID - "read the carbon pane", "what did bison say", "tell lima to rerun it" - before running any herdr pane or agent command. Also covers the plugin that assigns those labels.
---

# herdr-auto-name-pane

Herdr panes carry a short label (`neon`, `mars`, `lima`) shown on the pane border. Users refer to panes by that label; the `herdr` CLI only accepts pane IDs (`wFB:p1`). Resolve the label to an ID first.

Never claim a pane does not exist until you have checked the label column. The `herdr` skill documents pane IDs and agent names only, so an agent following it alone will not expect `pluto` to resolve.

## Resolve a label

Run `resolve.sh` from this skill's own directory (the base directory given when the skill loaded):

```sh
sh <skill-dir>/resolve.sh bison
```

It prints one pane ID on stdout. On a miss it exits 1; on an ambiguous label it exits 2 and writes the candidate list to stderr, so capture stderr too rather than acting on empty stdout. A pane ID passes through unchanged as long as it is present in the snapshot, so a pane created moments ago may still miss. Equivalent inline lookup when the script is not on hand:

```sh
herdr api snapshot | jq -r --arg t bison '
  [.result.snapshot.panes[]?
   | select(.pane_id == $t or (.label // "") == $t)
   | "\(.pane_id)\t\(.workspace_id // "?")"]
  | unique | .[]'
```

The pane ID is the first tab-separated field. More than one line means the label is duplicated across workspaces. Do not pick one silently: list the candidates with their workspace and ask which one.

## List panes with both columns

```sh
herdr api snapshot | jq -r '.result.snapshot.panes[]? | "\(.label // "-") \(.pane_id) \(.workspace_id)"'
```

`herdr api snapshot` is server-global and is the right source for a lookup. `herdr pane list` carries the same panes and the same `label` column, and is server-global too unless you narrow it with `--workspace <id>`.

## Then act on the ID

```sh
herdr pane read <id> --source recent-unwrapped --lines 200
herdr pane run <id> "just test"
herdr agent prompt <id> "..."
```

A pane ID is a valid agent target when that pane hosts an agent.

## Labels are not agent names

They are independent namespaces. A pane labeled `pika` can host an agent named `con-3570-client-portal-web`, and panes without an agent still get a label. Resolve a label through the panes list; resolve an agent name through `herdr agent list`.

## Naming

The plugin labels each new pane and every unlabeled pane at startup. Existing labels are never overwritten, names are unique across the server, and the list falls back to a numeric suffix (`neon-2`) when it runs out. To relabel by hand: `herdr pane rename <id> <label>`.
