/**
 * Builder primitives for the DevGuard Helm chart configuration schema.
 *
 * The schema is a single nested tree (see `schema.ts`). Plain JS values become
 * YAML directly. Wrap a value in `f(value, opts)` to attach:
 *   - `comment`      a leading comment rendered before the key (block comments,
 *                    section banners, commented-out examples)
 *   - `inline`       an inline comment rendered after the value
 *   - `blankBefore`  insert a blank line before the entry
 *   - `question`     Rancher question metadata (drives questions.yaml)
 *
 * Two generators walk the tree:
 *   - `generateValues`     -> values.yaml (full chart defaults + comments)
 *   - `generateQuestions`  -> questions.yaml (Rancher install form)
 */
import YAML, { isMap, isSeq, type Document } from "yaml";

/** Rancher question input types. Inferred from the value when omitted. */
export type RancherType =
  | "string"
  | "multiline"
  | "boolean"
  | "int"
  | "enum"
  | "password"
  | "storageclass"
  | "hostname"
  | "pvc"
  | "secret"
  | "cloudcredential";

export interface Question {
  /** Display label in the Rancher install form. */
  label: string;
  /** Group heading questions are bucketed under. See GROUP_ORDER in schema.ts. */
  group: string;
  /** Input type. Inferred from the field's value when omitted. */
  type?: RancherType;
  /** Whether Rancher marks the field as required. */
  required?: boolean;
  /** Help text shown beneath the field. */
  description?: string;
  /**
   * Default surfaced in the install form. Only emitted when set — note this is
   * intentionally independent of the values.yaml default (e.g. csaf secret name
   * is "" in values.yaml but "csaf-key-pair" as a question default).
   */
  default?: unknown;
  /** For boolean toggles: reveal subquestions when the value equals this. */
  showSubquestionIf?: unknown;
  /**
   * Override the derived variable path. The path is otherwise computed from the
   * field's position in the tree (e.g. `api.ingress.hosts[0].host`). Needed when
   * the Rancher variable diverges from the values.yaml path (e.g. `password`).
   */
  variable?: string;
  /**
   * Nest this question as a subquestion of another. Value is the parent's
   * (derived or overridden) variable path.
   */
  subquestionOf?: string;
}

export interface FieldOpts {
  comment?: string;
  inline?: string;
  /**
   * A comment rendered after the value. On a map/array it becomes a trailing
   * comment block inside the collection — handy for commented-out optional keys.
   */
  trailingComment?: string;
  blankBefore?: boolean;
  question?: Question;
}

export class Field {
  constructor(
    public readonly value: unknown,
    public readonly opts: FieldOpts = {},
  ) { }
}

/** Wrap any value (scalar, object, or array) to attach comments / question metadata. */
export function f(value: unknown, opts: FieldOpts = {}): Field {
  return new Field(value, opts);
}

export const isField = (x: unknown): x is Field => x instanceof Field;

type Path = (string | number)[];

/** Recursively unwrap Fields into a plain value tree for YAML serialization. */
function strip(node: unknown): unknown {
  if (isField(node)) return strip(node.value);
  if (Array.isArray(node)) return node.map(strip);
  if (node && typeof node === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(node as Record<string, unknown>)) {
      out[k] = strip(v);
    }
    return out;
  }
  return node;
}

interface CommentRec {
  path: Path;
  comment?: string;
  inline?: string;
  trailingComment?: string;
  blankBefore?: boolean;
}

/** Walk the original (Field-bearing) tree, recording where comments live. */
function collectComments(node: unknown, path: Path, acc: CommentRec[]): void {
  if (isField(node)) {
    const { comment, inline, trailingComment, blankBefore } = node.opts;
    if (comment || inline || trailingComment || blankBefore) {
      acc.push({ path, comment, inline, trailingComment, blankBefore });
    }
    collectComments(node.value, path, acc);
    return;
  }
  if (Array.isArray(node)) {
    node.forEach((v, i) => collectComments(v, [...path, i], acc));
    return;
  }
  if (node && typeof node === "object") {
    for (const [k, v] of Object.entries(node as Record<string, unknown>)) {
      collectComments(v, [...path, k], acc);
    }
  }
}

interface Located {
  kind: "map" | "seq";
  key?: any;
  value: any;
  item?: any;
}

/** Resolve a path to its Pair (map entry) or item node within the document. */
function locate(doc: Document, path: Path): Located | null {
  let node: any = doc.contents;
  for (let i = 0; i < path.length - 1; i++) {
    const seg = path[i];
    if (isSeq(node)) node = node.items[seg as number];
    else if (isMap(node)) {
      const pair = node.items.find(
        (p: any) => String(p.key?.value) === String(seg),
      );
      if (!pair) return null;
      node = pair.value;
    } else return null;
  }
  const last = path[path.length - 1];
  if (isSeq(node)) {
    const item = node.items[last as number];
    return { kind: "seq", value: item, item };
  }
  if (isMap(node)) {
    const pair = node.items.find(
      (p: any) => String(p.key?.value) === String(last),
    );
    if (!pair) return null;
    return { kind: "map", key: pair.key, value: pair.value };
  }
  return null;
}

/** Prefix every line of a comment with a single space (yaml renders `#<text>`). */
function fmtComment(text: string): string {
  return text
    .split("\n")
    .map((l) => (l.length === 0 ? "" : l.startsWith("#") ? l : " " + l))
    .join("\n");
}

/**
 * A three-line section banner. The yaml library prepends one `#` to each line,
 * so the authored content carries one fewer `#` than the rendered output.
 */
export function banner(title: string): string {
  const bar = "#".repeat(95);
  return `${bar}\n# ${title}\n#####`;
}

/** Generate the full values.yaml string (defaults + comments). */
export function generateValues(tree: Record<string, unknown>): string {
  const plain = strip(tree) as Record<string, unknown>;
  const doc = new YAML.Document(plain);

  const recs: CommentRec[] = [];
  collectComments(tree, [], recs);

  for (const rec of recs) {
    const loc = locate(doc, rec.path);
    if (!loc) {
      throw new Error(`Could not locate node for path ${rec.path.join(".")}`);
    }
    const anchor = loc.kind === "map" ? loc.key : loc.item;
    if (rec.blankBefore) anchor.spaceBefore = true;
    if (rec.comment) anchor.commentBefore = fmtComment(rec.comment);
    if (rec.inline) loc.value.comment = fmtComment(rec.inline);
    if (rec.trailingComment) loc.value.comment = fmtComment(rec.trailingComment);
  }

  return doc.toString({ lineWidth: 0 });
}

interface FlatQuestion {
  variable: string;
  q: Question;
  value: unknown;
  order: number;
}

/** Collect every Field carrying question metadata, with its derived variable path. */
function collectQuestions(
  node: unknown,
  path: Path,
  acc: FlatQuestion[],
): void {
  if (isField(node)) {
    if (node.opts.question) {
      const q = node.opts.question;
      acc.push({
        variable: q.variable ?? pathToVariable(path),
        q,
        value: node.value,
        order: acc.length,
      });
    }
    collectQuestions(node.value, path, acc);
    return;
  }
  if (Array.isArray(node)) {
    node.forEach((v, i) => collectQuestions(v, [...path, i], acc));
    return;
  }
  if (node && typeof node === "object") {
    for (const [k, v] of Object.entries(node as Record<string, unknown>)) {
      collectQuestions(v, [...path, k], acc);
    }
  }
}

/** ["api","ingress","hosts",0,"host"] -> "api.ingress.hosts[0].host" */
function pathToVariable(path: Path): string {
  let out = "";
  for (const seg of path) {
    if (typeof seg === "number") out += `[${seg}]`;
    else out += out ? `.${seg}` : seg;
  }
  return out;
}

function inferType(value: unknown): RancherType {
  if (typeof value === "boolean") return "boolean";
  // Rancher has no float input type; numbers map to int (use an explicit
  // `type` in the schema for non-integer numeric fields).
  if (typeof value === "number") return "int";
  return "string";
}

/** Serialize one question into the Rancher key order (omitting unset fields). */
function questionObject(fq: FlatQuestion): Record<string, unknown> {
  const { q, variable, value } = fq;
  const obj: Record<string, unknown> = { variable };
  if (q.default !== undefined) obj.default = q.default;
  if (q.required !== undefined) obj.required = q.required;
  obj.type = q.type ?? inferType(value);
  obj.label = q.label;
  if (q.description) obj.description = q.description;
  obj.group = q.group;
  if (q.showSubquestionIf !== undefined)
    obj.show_subquestion_if = q.showSubquestionIf;
  return obj;
}

/**
 * Generate the Rancher questions.yaml string.
 * @param tree        the schema tree
 * @param groupOrder  group headings in display order; questions are sorted by
 *                    (group index, encounter order) so output order is stable
 *                    regardless of where fields sit in the tree.
 */
export function generateQuestions(
  tree: Record<string, unknown>,
  groupOrder: string[],
): string {
  const flat: FlatQuestion[] = [];
  collectQuestions(tree, [], flat);

  const byVariable = new Map(flat.map((f) => [f.variable, f]));
  const subOf = new Map<string, FlatQuestion[]>();
  const topLevel: FlatQuestion[] = [];

  for (const fq of flat) {
    const parent = fq.q.subquestionOf;
    if (parent) {
      if (!byVariable.has(parent)) {
        throw new Error(
          `subquestionOf "${parent}" for "${fq.variable}" has no matching parent question`,
        );
      }
      const list = subOf.get(parent) ?? [];
      list.push(fq);
      subOf.set(parent, list);
    } else {
      topLevel.push(fq);
    }
  }

  const groupIndex = (g: string) => {
    const i = groupOrder.indexOf(g);
    return i === -1 ? groupOrder.length : i;
  };
  topLevel.sort((a, b) => {
    const gi = groupIndex(a.q.group) - groupIndex(b.q.group);
    return gi !== 0 ? gi : a.order - b.order;
  });

  const questions = topLevel.map((fq) => {
    const obj = questionObject(fq);
    const subs = subOf.get(fq.variable);
    if (subs) obj.subquestions = subs.map(questionObject);
    return obj;
  });

  const doc = new YAML.Document({ questions });

  // Add a blank line before the first question of each new group, mirroring the
  // visual grouping of the original file.
  const items: any = (doc.getIn(["questions"], true) as any)?.items ?? [];
  let prevGroup: string | undefined;
  for (let i = 0; i < items.length; i++) {
    const g = topLevel[i]?.q.group;
    if (i > 0 && g !== prevGroup) items[i].spaceBefore = true;
    prevGroup = g;
  }

  // indentSeq: false keeps list items flush with their key, matching Rancher's
  // conventional questions.yaml style (`subquestions:\n  - variable: ...`).
  return doc.toString({ lineWidth: 0, indentSeq: false });
}
