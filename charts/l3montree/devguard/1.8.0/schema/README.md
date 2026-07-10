# Chart configuration schema

`values.yaml` (this chart's defaults) and the Rancher `questions.yaml` are
**generated** from [`schema.ts`](./schema.ts). It is the single source of truth —
edit it, never the generated files.

## Usage

```bash
cd schema
bun install
bun run generate     # write values.yaml + questions.yaml
bun run check        # CI: exit 1 if the generated files are stale
```

Outputs:

| File             | Location                                                             | Notes                                                                   |
| ---------------- | -------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| `values.yaml`    | chart root                                                           | fully generated                                                         |
| `Chart.yaml`     | chart root                                                           | `version` + `appVersion` patched from `devguardVersion`; rest untouched |
| `questions.yaml` | `../rancher-partner-charts/packages/devguard/overlay/questions.yaml` | fully generated                                                         |

`devguardVersion` in `schema.ts` (plain semver, e.g. `1.7.0`) is the single
version knob: it sets the api/web/postgresql image tags (`v`-prefixed), and
`Chart.yaml`'s `version` (as-is) and `appVersion` (`v`-prefixed, quoted).

The partner-charts path assumes that repo sits next to this one. Override it:

```bash
PARTNER_QUESTIONS=/path/to/overlay/questions.yaml bun run generate
```

## How it works

- [`schema.ts`](./schema.ts) is one nested tree. Plain values render straight
  into `values.yaml`. Wrap a value in `f(value, opts)` to attach a `comment`,
  an `inline` comment, a `blankBefore` blank line, or Rancher `question`
  metadata.
- [`builder.ts`](./builder.ts) holds `f()` and the two generators.
  `generateValues` emits the commented `values.yaml`; `generateQuestions`
  collects every field carrying `question` metadata into the Rancher form.

### Adding a value

Add a key anywhere in the tree:

```ts
api: {
  newSetting: f("default", { comment: "what it does" }),
}
```

### Exposing a value in the Rancher install form

Attach `question` metadata. The `variable` path is derived from the field's
position in the tree (e.g. `api.ingress.hosts[0].host`); override it when the
Rancher variable differs.

```ts
api: {
  newSetting: f("default", {
    question: {
      label: "New Setting",
      group: "API (required for web and API access)",
      type: "string",
      required: true,
    },
  }),
}
```

- `subquestionOf: "<parent variable>"` nests a question under a boolean toggle
  (the toggle sets `showSubquestionIf`).
- Group order is controlled by `GROUP_ORDER` in `schema.ts`, not by tree
  position. Within a group, questions follow tree order unless given an `order`.
- A question's `default` is independent of the `values.yaml` default — only
  emitted when set.

## Note on fidelity

The generated files are **data-identical** to the originals (verified by parsing
both and deep-comparing). Some cosmetic details differ — YAML quoting of values
that don't require quotes, section-banner width, and block vs flow sequences —
but the parsed configuration is the same.
