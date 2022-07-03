// require nodejs 8, npm install plist

var fs = require('fs');
var plist = require('plist');
const util = require('util');
const exec = util.promisify(require('child_process').exec);

const img = './Z_my.png';
const plist_file = './Z_my.plist';

const obj = plist.parse(fs.readFileSync(plist_file, 'utf8'));

async function main() {
  for (const [filename, info] of Object.entries(obj.frames)) {
    const r = info.frame.match(/(\d+),(\d+)\D+(\d+),(\d+)/);
    r.shift();
    const [x, y, w, h] = r.map(x => Number.parseInt(x));
    if (info.rotated) {
      await exec( `magick ${img} -crop ${h}x${w}+${x}+${y} -rotate -90 ${filename}`);
    } else {
      await exec(`magick ${img} -crop ${w}x${h}+${x}+${y} ${filename}`);
    }
  }
}

main();

// magick t.png -crop 113x75+2+2  -rotate "-90" out.png
