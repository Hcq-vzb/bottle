/**
 * Remove semi-transparent repeating ECENG watermark from product photos.
 * Usage: node remove-watermark.js <input.jpg> [output.jpg]
 */
const { Jimp } = require('jimp');
const path = require('path');
const fs = require('fs');

function saturation(r, g, b) {
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  return max === 0 ? 0 : (max - min) / max;
}

function isWatermarkPixel(r, g, b, br, bg, bb) {
  const diff = Math.abs(r - br) + Math.abs(g - bg) + Math.abs(b - bb);
  const sat = saturation(r, g, b);

  // Solid brand orange on machine/footer — keep
  if (sat > 0.62 && r > 170 && g < 160) return false;
  if (r > 200 && g > 200 && b > 200) return false;

  // Watermark on dark machine panels
  if (r < 100 && g < 100 && b < 100) {
    return (
      r > g + 4 &&
      g >= b - 2 &&
      diff >= 3 &&
      diff <= 45 &&
      r >= 25
    );
  }

  // Repeating watermark: muted orange-brown overlay on grey/white
  const orangeBrown =
    r > g &&
    g >= b - 8 &&
    r - b >= 12 &&
    r - b <= 95 &&
    sat >= 0.06 &&
    sat <= 0.42 &&
    r >= 115 &&
    r <= 228;

  if (!orangeBrown) return false;
  return diff >= 4 && diff <= 90;
}

async function removeWatermark(inputPath, outputPath) {
  const img = await Jimp.read(inputPath);
  const blur = img.clone();
  blur.blur(10);

  const w = img.bitmap.width;
  const h = img.bitmap.height;
  const data = img.bitmap.data;
  const blurData = blur.bitmap.data;
  const mask = new Uint8Array(w * h);

  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const idx = (y * w + x) * 4;
      const r = data[idx];
      const g = data[idx + 1];
      const b = data[idx + 2];
      const br = blurData[idx];
      const bg = blurData[idx + 1];
      const bb = blurData[idx + 2];
      if (isWatermarkPixel(r, g, b, br, bg, bb)) {
        mask[y * w + x] = 1;
      }
    }
  }

  // Expand mask slightly to cover watermark edges
  const dilated = new Uint8Array(mask);
  for (let y = 1; y < h - 1; y++) {
    for (let x = 1; x < w - 1; x++) {
      const i = y * w + x;
      if (
        mask[i] ||
        mask[i - 1] ||
        mask[i + 1] ||
        mask[i - w] ||
        mask[i + w]
      ) {
        dilated[i] = 1;
      }
    }
  }

  // Inpaint: replace masked pixels with median of nearby unmasked neighbors
  for (let pass = 0; pass < 2; pass++) {
    for (let y = 1; y < h - 1; y++) {
      for (let x = 1; x < w - 1; x++) {
        const i = y * w + x;
        if (!dilated[i]) continue;
        const rs = [];
        const gs = [];
        const bs = [];
        for (let dy = -2; dy <= 2; dy++) {
          for (let dx = -2; dx <= 2; dx++) {
            const j = (y + dy) * w + (x + dx);
            if (!dilated[j]) {
              const idx = j * 4;
              rs.push(data[idx]);
              gs.push(data[idx + 1]);
              bs.push(data[idx + 2]);
            }
          }
        }
        if (rs.length < 4) continue;
        rs.sort((a, b) => a - b);
        gs.sort((a, b) => a - b);
        bs.sort((a, b) => a - b);
        const mid = Math.floor(rs.length / 2);
        const idx = i * 4;
        const blend = pass === 0 ? 0.75 : 0.55;
        data[idx] = data[idx] * (1 - blend) + rs[mid] * blend;
        data[idx + 1] = data[idx + 1] * (1 - blend) + gs[mid] * blend;
        data[idx + 2] = data[idx + 2] * (1 - blend) + bs[mid] * blend;
      }
    }
  }

  // Final gentle blur blend on remaining watermark tint
  const blur2 = img.clone();
  blur2.blur(3);
  const blur2Data = blur2.bitmap.data;
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const idx = (y * w + x) * 4;
      const r = data[idx];
      const g = data[idx + 1];
      const b = data[idx + 2];
      if (
        isWatermarkPixel(
          r,
          g,
          b,
          blur2Data[idx],
          blur2Data[idx + 1],
          blur2Data[idx + 2]
        )
      ) {
        data[idx] = r * 0.35 + blur2Data[idx] * 0.65;
        data[idx + 1] = g * 0.35 + blur2Data[idx + 1] * 0.65;
        data[idx + 2] = b * 0.35 + blur2Data[idx + 2] * 0.65;
      }
    }
  }

  await img.write(outputPath);
  console.log('OK:', outputPath);
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    console.error('Usage: node remove-watermark.js <input> [output]');
    process.exit(1);
  }
  const input = args[0];
  const output =
    args[1] ||
    input.replace(/(\.[a-z]+)$/i, '-nowm$1');
  await removeWatermark(input, output);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
