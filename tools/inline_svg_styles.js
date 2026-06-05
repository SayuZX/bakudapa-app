const fs = require('fs');
const path = require('path');

const input = path.resolve(__dirname, '..', 'assets', 'images', 'logo-malut.svg');
const backup = input.replace(/\.svg$/, '.original.svg');
const output = input;

const raw = fs.readFileSync(input, 'utf8');

if (!fs.existsSync(backup)) {
  fs.writeFileSync(backup, raw, 'utf8');
}

const styleMatch = raw.match(/<style>\s*<!\[CDATA\[(.*?)\]\]>\s*<\/style>/s);
if (!styleMatch) {
  console.error('No <style><![CDATA[...]]></style> block found.');
  process.exit(1);
}
const css = styleMatch[1];

const classMap = {};
const ruleRe = /\.([a-zA-Z_][\w-]*)\s*\{\s*([^}]+?)\s*\}/g;
let m;
while ((m = ruleRe.exec(css)) !== null) {
  const cls = m[1];
  const decls = m[2].split(';').map(s => s.trim()).filter(Boolean);
  const props = {};
  for (const d of decls) {
    const [prop, value] = d.split(':').map(s => s && s.trim());
    if (prop && value) props[prop] = value;
  }
  classMap[cls] = props;
}

console.log('Parsed classes:', Object.keys(classMap).join(', '));

let svg = raw.replace(styleMatch[0], '');

svg = svg.replace(/class="([^"]+)"/g, (full, classes) => {
  const names = classes.split(/\s+/).filter(Boolean);
  const merged = {};
  for (const n of names) {
    const props = classMap[n];
    if (!props) continue;
    Object.assign(merged, props);
  }
  if (Object.keys(merged).length === 0) return '';
  const attrs = Object.entries(merged)
    .map(([k, v]) => `${k}="${v}"`)
    .join(' ');
  return attrs;
});

svg = svg.replace(/\s{2,}/g, ' ');
svg = svg.replace(/>\s+</g, '><');

fs.writeFileSync(output, svg, 'utf8');
console.log(`Wrote inlined SVG: ${output}`);
console.log(`Backup saved at:   ${backup}`);
console.log(`Size: ${raw.length} -> ${svg.length} bytes`);
