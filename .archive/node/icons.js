const icon_size = [100, 114, 120, 144, 152, 180, 29, 40, 50, 57, 58, 72, 76, 80, 87]

const inputImg = process.argv[2];

const exec = require('child_process').exec;

const fs = require('fs');
if (fs.existsSync(inputImg)) {
  console.log(`处理图片: ${inputImg}`);
  for (const width of icon_size) {
    const height = width;
    const cmd = `magick ${inputImg} -resize ${width}x${height} icon-${width}.png`;
    //console.log(cmd);
    exec(cmd);
  }

} else {
  console.log('使用方法:');
  console.log('\t先安装(homebrew) imagemagick; brew install imagemagick');
  console.log('\tnode icons.js 图片名');
}
