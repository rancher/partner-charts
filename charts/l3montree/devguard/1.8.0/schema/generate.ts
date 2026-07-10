/**
 * Generates values.yaml and questions.yaml from the schema in `schema.ts`, and
 * keeps Chart.yaml's version/appVersion in sync with `devguardVersion`.
 *
 *   bun run generate          write all outputs
 *   bun run generate --check  fail (exit 1) if any output is stale — for CI
 *
 * Outputs:
 *   - <repo>/values.yaml
 *   - <repo>/questions.yaml
 *   - <repo>/Chart.yaml                          (version + appVersion only)
 *   - <partner-charts overlay>/questions.yaml   (sibling repo, see PARTNER_QUESTIONS)
 */
import { resolve, dirname } from "node:path";
import { existsSync } from "node:fs";
import { generateValues, generateQuestions } from "./builder";
import { schema, GROUP_ORDER, devguardVersion } from "./schema";

const HEADER =
  "# DO NOT EDIT — generated from schema/schema.ts. Run `bun run generate` in schema/.\n";

const repoRoot = resolve(import.meta.dir, "..");

// The partner-charts repo is expected to sit next to devguard-helm-chart.
// Override with the PARTNER_QUESTIONS env var if your layout differs.
const PARTNER_QUESTIONS =
  process.env.PARTNER_QUESTIONS ??
  resolve(
    repoRoot,
    "..",
    "rancher-partner-charts/packages/l3montree/devguard/overlay/questions.yaml",
  );

const valuesYaml = generateValues(schema);
const questionsYaml = generateQuestions(schema, GROUP_ORDER);

// Chart.yaml is only partially generated: we patch the `version` (semver) and
// `appVersion` (the image tag, `v`-prefixed and quoted) lines in place and
// leave the rest of the file — comments and all — untouched.
const chartPath = resolve(repoRoot, "Chart.yaml");
function patchChart(src: string): string {
  let patched = 0;
  const out = src
    .replace(/^version:.*$/m, () => (patched++, `version: ${devguardVersion}`))
    .replace(/^appVersion:.*$/m, () => (patched++, `appVersion: "v${devguardVersion}"`));
  if (patched !== 2) {
    throw new Error(
      `Chart.yaml: expected to patch 'version' and 'appVersion' but matched ${patched} line(s)`,
    );
  }
  return out;
}
const chartYaml = patchChart(await Bun.file(chartPath).text());

// `optional` outputs (the sibling partner-charts overlay) are skipped when
// their target directory is absent — e.g. in CI, where that repo isn't checked
// out. The in-repo files are always validated.
const outputs: {
  path: string;
  content: string;
  header: boolean;
  optional?: boolean;
}[] = [
    { path: resolve(repoRoot, "values.yaml"), content: valuesYaml, header: true },
    { path: chartPath, content: chartYaml, header: false },
    { path: PARTNER_QUESTIONS, content: questionsYaml, header: true, optional: true },
  ];

const check = process.argv.includes("--check");
let stale = false;

for (const out of outputs) {
  if (out.optional && !existsSync(dirname(out.path))) {
    console.log(`skipped (not present): ${out.path}`);
    continue;
  }
  const content = (out.header ? HEADER : "") + out.content;
  if (check) {
    const existing = await Bun.file(out.path)
      .text()
      .catch(() => null);
    if (existing !== content) {
      console.error(`stale: ${out.path}`);
      stale = true;
    }
    continue;
  }
  await Bun.write(out.path, content);
  console.log(`wrote ${out.path}`);
}

if (check && stale) {
  console.error("\nOutputs are stale. Run `bun run generate`.");
  process.exit(1);
}
if (check) console.log("all outputs up to date");
