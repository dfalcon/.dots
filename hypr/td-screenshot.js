const { execSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

fs.appendFileSync('/tmp/td-screenshot.log', '[' + new Date().toISOString() + '] module loaded\n');

function takeScreenshot(displayId, filePath, blurRadius, base64, callback) {
  try {
    const tmp = path.join(os.tmpdir(), '.tdg_' + process.pid + '_' + Date.now() + '.jpg');
    fs.appendFileSync('/tmp/td-screenshot.log', '[' + new Date().toISOString() + '] takeScreenshot called\n');
    execSync('/usr/bin/grim -t jpeg -q 85 ' + JSON.stringify(tmp), { timeout: 10000 });
    if (base64) {
      const data = fs.readFileSync(tmp);
      fs.unlinkSync(tmp);
      callback(null, 1, data.toString('base64'));
    } else {
      fs.renameSync(tmp, filePath);
      callback(null, 1, filePath);
    }
  } catch (err) {
    callback(err, 0, null);
  }
}

module.exports = {
  screenshooter: {
    takeScreenshot,
    takeScreenshotWithPromise: (d, f, b = 0, b64 = true) =>
      new Promise((res, rej) => takeScreenshot(d, f, b, b64, (e, c, file) => e ? rej(e) : res(file))),
  },
  setLogger: () => {},
};
