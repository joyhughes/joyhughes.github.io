import Module from './tsp.js';

let tspModule = null;

Module().then((initializedModule) => {
  tspModule = initializedModule;
  console.log("Emscripten Module Initialized");

  self.addEventListener('message', (event) => {
    if (event.data.action === 'runTSP') {
      const numPoints = event.data.numPoints;
      try {
        const callback = (interimJson) => {
          // Send interim points to the main thread
          self.postMessage({ action: 'interimTSP', result: interimJson });
        };

        const result = tspModule.runTSP(numPoints, callback);
        // Send the final result to the main thread
        self.postMessage({ action: 'tspResult', result: result });
      } catch (error) {
        console.error("Error running TSP:", error);
        self.postMessage({ action: 'tspError', message: error.message });
      }
    }
  });
});
