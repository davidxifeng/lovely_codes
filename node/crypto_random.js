const crypto = require('crypto');

const r = [];
for (let i = 0; i < 128; i++) {
  r.push(crypto.randomBytes(1).readUInt8());
}
console.log(JSON.stringify(r.sort((a,b) => a - b)));
