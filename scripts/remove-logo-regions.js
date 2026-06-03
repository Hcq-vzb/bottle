/**
 * Remove ECENG logo blocks (top-left branding + machine badge) + repeating watermark.
 */
const { Jimp } = require('jimp');

function saturation(r, g, b) {
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  return max === 0 ? 0 : (max - min) / max;
}

function isRepeatingWatermark(r, g, b, br, bg, bb) {
  const diff = Math.abs(r - br) + Math.abs(g - bg) + Math.abs(b - bb);
  const sat = saturation(r, g, b);
  if (sat > 0.62 && r > 170 && g < 160) return false;
  if (r > 200 && g > 200 && b > 200) return false;
  if (r < 100 && g < 100 && b < 100) {
    return r > g + 4 && g >= b - 2 && diff >= 3 && diff <= 45 && r >= 25;
  }
  const orangeBrown =
    r > g && g >= b - 8 && r - b >= 12 && r - b <= 95 &&
    sat >= 0.06 && sat <= 0.42 && r >= 115 && r <= 228;
  return orangeBrown && diff >= 4 && diff <= 90;
}

function median(arr) {
  if (!arr.length) return 0;
  const s = arr.slice().sort((a, b) => a - b);
  return s[Math.floor(s.length / 2)];
}

function sampleColor(data, w, h, regions) {
  const rs = [];
  const gs = [];
  const bs = [];
  for (const [x0, y0, x1, y1] of regions) {
    for (let y = y0; y < y1; y += 2) {
      for (let x = x0; x < x1; x += 2) {
        const idx = (y * w + x) * 4;
        const r = data[idx];
        const g = data[idx + 1];
        const b = data[idx + 2];
        const sat = saturation(r, g, b);
        if (sat > 0.45 && r > 140 && g < 130) continue;
        rs.push(r);
        gs.push(g);
        bs.push(b);
      }
    }
  }
  return [median(rs), median(gs), median(bs)];
}

function fillRegion(data, w, h, x0, y0, x1, y1, color, noise = 0) {
  const [r0, g0, b0] = color;
  for (let y = y0; y <= y1; y++) {
    for (let x = x0; x <= x1; x++) {
      const idx = (y * w + x) * 4;
      const n = noise ? Math.round((Math.random() - 0.5) * noise * 2) : 0;
      data[idx] = Math.max(0, Math.min(255, r0 + n));
      data[idx + 1] = Math.max(0, Math.min(255, g0 + n));
      data[idx + 2] = Math.max(0, Math.min(255, b0 + n));
    }
  }
}

function blendRegionEdges(data, w, h, x0, y0, x1, y1, feather = 10) {
  for (let y = Math.max(0, y0 - feather); y <= Math.min(h - 1, y1 + feather); y++) {
    for (let x = Math.max(0, x0 - feather); x <= Math.min(w - 1, x1 + feather); x++) {
      const inside = x >= x0 && x <= x1 && y >= y0 && y <= y1;
      const dx = x < x0 ? x0 - x : x > x1 ? x - x1 : 0;
      const dy = y < y0 ? y0 - y : y > y1 ? y - y1 : 0;
      const dist = inside ? 0 : Math.sqrt(dx * dx + dy * dy);
      if (dist > feather) continue;
      const t = inside ? 0 : dist / feather;
      const blend = 0.55 * t;
      const idx = (y * w + x) * 4;
      const r = data[idx];
      const g = data[idx + 1];
      const b = data[idx + 2];
      const sx = Math.min(w - 1, Math.max(0, x0 + Math.floor((x1 - x0) / 2)));
      const sy = Math.min(h - 1, y1 + 1);
      const sidx = (sy * w + sx) * 4;
      data[idx] = r * (1 - blend) + data[sidx] * blend;
      data[idx + 1] = g * (1 - blend) + data[sidx + 1] * blend;
      data[idx + 2] = b * (1 - blend) + data[sidx + 2] * blend;
    }
  }
}

async function removeLogosAndWatermark(inputPath, outputPath) {
  const img = await Jimp.read(inputPath);
  const w = img.bitmap.width;
  const h = img.bitmap.height;
  const data = img.bitmap.data;

  const blur = img.clone();
  blur.blur(10);
  const blurData = blur.bitmap.data;
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const idx = (y * w + x) * 4;
      if (isRepeatingWatermark(
        data[idx], data[idx + 1], data[idx + 2],
        blurData[idx], blurData[idx + 1], blurData[idx + 2]
      )) {
        const blend = 0.88;
        data[idx] = data[idx] * (1 - blend) + blurData[idx] * blend;
        data[idx + 1] = data[idx + 1] * (1 - blend) + blurData[idx + 1] * blend;
        data[idx + 2] = data[idx + 2] * (1 - blend) + blurData[idx + 2] * blend;
      }
    }
  }

  const greyBg = sampleColor(data, w, h, [
    [Math.round(w * 0.56), Math.round(h * 0.02), Math.round(w * 0.70), Math.round(h * 0.10)],
    [Math.round(w * 0.50), Math.round(h * 0.32), Math.round(w * 0.58), Math.round(h * 0.40)],
  ]);

  const tlX1 = Math.round(w * 0.50);
  const tlY1 = Math.round(h * 0.36);
  fillRegion(data, w, h, 0, 0, tlX1, tlY1, greyBg, 3);
  blendRegionEdges(data, w, h, 0, 0, tlX1, tlY1, 12);

  const panelBlack = sampleColor(data, w, h, [
    [Math.round(w * 0.72), Math.round(h * 0.54), Math.round(w * 0.77), Math.round(h * 0.62)],
  ]);

  const brX0 = Math.round(w * 0.83);
  const brY0 = Math.round(h * 0.72);
  const brX1 = Math.round(w * 0.94);
  const brY1 = Math.round(h * 0.84);
  fillRegion(data, w, h, brX0, brY0, brX1, brY1, panelBlack, 2);
  blendRegionEdges(data, w, h, brX0, brY0, brX1, brY1, 6);

  await img.write(outputPath);
  console.log('OK:', outputPath);
}

async function main() {
  const input = process.argv[2];
  const output = process.argv[3] || input.replace(/(\.[a-z]+)$/i, '-nowm$1');
  if (!input) {
    console.error('Usage: node remove-logo-regions.js <input> [output]');
    process.exit(1);
  }
  await removeLogosAndWatermark(input, output);
}

main().catch((e) => { console.error(e); process.exit(1); });
