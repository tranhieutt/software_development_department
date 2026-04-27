#!/usr/bin/env node
// One-shot SVG → PNG converter using @resvg/resvg-js
// Usage: node scripts/svg-to-png.js <input.svg> <output.png> [scale]

const fs = require('fs');
const path = require('path');
const { Resvg } = require('@resvg/resvg-js');

const [, , inputPath, outputPath, scaleArg] = process.argv;
if (!inputPath || !outputPath) {
  console.error('Usage: node scripts/svg-to-png.js <input.svg> <output.png> [scale=2]');
  process.exit(1);
}

const scale = Number(scaleArg) || 2;
const svg = fs.readFileSync(path.resolve(inputPath), 'utf8');

const resvg = new Resvg(svg, {
  fitTo: { mode: 'zoom', value: scale },
  font: {
    loadSystemFonts: true,
    defaultFontFamily: 'Segoe UI',
  },
  background: '#ffffff',
});

const png = resvg.render().asPng();
fs.writeFileSync(path.resolve(outputPath), png);
const { width, height } = resvg.render();
console.log(`OK: ${outputPath} (${png.length} bytes, scale=${scale}x)`);
