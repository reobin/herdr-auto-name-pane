# Auto-name pane

Herdr panes have easy labels (`neon`, `mars`, `lima`) shown on pane borders. The CLI only accepts pane IDs (`wFB:p1`), so resolve the label first. Never claim a pane does not exist until you have checked the label column.

List panes with both columns:

```sh
herdr api snapshot | jq -r '.result.snapshot.panes[]? | "\(.label // "") \(.pane_id)"'
```

Resolve one label to an ID (pane IDs pass through unchanged):

```sh
herdr api snapshot | jq -r --arg t "bison" '
  (.result.snapshot.panes[]? | select(.pane_id == $t) | .pane_id),
  (.result.snapshot.panes[]? | select((.label // "") == $t) | .pane_id)' | head -n 1
```

Then act on the ID: `herdr pane read <id>`, `herdr pane run <id> "..."`, `herdr agent prompt <id> "..."`. A pane ID is a valid agent target when that pane hosts an agent. When the repo checkout has `scripts/resolve.sh`, run `sh scripts/resolve.sh bison` from the plugin root for the same lookup.
