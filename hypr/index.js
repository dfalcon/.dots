const { Screenshooter, setLogger } = require('bindings')('screenshooter');

const screenshooter = new Screenshooter();

// promisified version of takeScreenshot()
screenshooter.takeScreenshotWithPromise = (displayId, filePath, blurRadius = 0, base64 = true) =>
  // eslint-disable-next-line promise/avoid-new
  new Promise((resolve, reject) => {
    try {
      screenshooter.takeScreenshot(displayId, filePath, blurRadius, base64, (error, displayCount, file) => {
        if (error) {
          return reject(error);
        }
        return resolve(file);
      });
    } catch (error) {
      reject(error);
    }
  });

module.exports = {
  screenshooter,
  setLogger,
};
