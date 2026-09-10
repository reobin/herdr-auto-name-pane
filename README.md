# herdr-auto-name-pane

Labels every herdr pane with a short, memorable name (`neon`, `mars`, `lima`), so you and your agent can refer to panes by name instead of ID.

## Install

```sh
herdr plugin install reobin/herdr-auto-name-pane
herdr plugin action invoke reobin.auto-name-pane.install-skill
```

The second command installs the `herdr-auto-name-pane` skill into this machine's agent skill directories, for Claude and `~/.agents`-style harnesses. Check it landed with `herdr plugin log list --plugin reobin.auto-name-pane`.

## Use

You never type pane IDs. Say the label:

* to an agent: `check output of pane bison`, `tell the agent in lima pane to rerun the scan`.
* the agent resolves the label to a pane ID with the `herdr api snapshot` filter from the skill, then runs `herdr pane read <id>` or `herdr agent prompt <id>`.

A label duplicated across workspaces is never guessed. The agent lists the candidates with their workspace and asks which one.

## Rules

* Existing labels are never overwritten.
* Names are unique across the server.
* Once the word list is exhausted, names join words (`bison-wapiti`, then a third, and so on). No cap on pane count.
* Labels and agent names are independent. A pane labeled `pika` can host an agent named `reviewer`.
