# DevGuard Helm Chart — Agent Notes

Read [ARCHITECTURE.md](ARCHITECTURE.md) first — it covers the chart structure, the schema generator, Rancher constraints, versioning, and working conventions.

## The single most important rule

`values.yaml`, the Rancher `questions.yaml`, and `version`/`appVersion` in `Chart.yaml` are **generated** from [`schema/schema.ts`](schema/schema.ts). **Never hand-edit them** — edit `schema.ts`, then:

```bash
cd schema && bun run generate
```

Commit the regenerated files together with the `schema.ts` change. CI (`schema-check`) fails if they're out of sync.
