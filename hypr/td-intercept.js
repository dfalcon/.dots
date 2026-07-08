const Module = require('module');
const { execSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const _load = Module._load.bind(Module);
fs.appendFileSync('/tmp/td-intercept.log', '[' + new Date().toISOString() + '] intercept loaded pid=' + process.pid + '\n');
Module._load = function(request, parent, isMain) {
  const mod = _load(request, parent, isMain);
  if (request && request.includes('node-screenshot')) {
    fs.appendFileSync('/tmp/td-intercept.log', '[' + new Date().toISOString() + '] node-screenshot loaded pid=' + process.pid + '\n');
  }
  if (request && request.includes('node-screenshot') && mod && mod.screenshooter) {
    mod.screenshooter.takeScreenshot = function(displayId, filePath, blurRadius, base64, callback) {
      try {
        const tmp = path.join(os.tmpdir(), '.tdg_' + process.pid + '_' + Date.now() + '.jpg');
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
    };
    mod.screenshooter.takeScreenshotWithPromise = (d, f, b, b64) =>
      new Promise((res, rej) =>
        mod.screenshooter.takeScreenshot(d, f, b, b64 === undefined ? true : b64,
          (e, c, file) => e ? rej(e) : res(file)));
  }
  return mod;
};
