import Module from './tsp.js';

let tspModule = null;

Module().then((initializedModule) => {
    tspModule = initializedModule;
    console.log("Emscripten Module Initialized"); // Log to verify initialization

    // Listen for messages from the main thread
    self.addEventListener('message', (event) => {
        console.log("Worker received a message:", event.data); // Log to verify message reception

        if (event.data.action === 'runTSP') {
            const numPoints = event.data.numPoints;
            try {
                if (!tspModule) {
                    throw new Error("Module not initialized");
                }
                console.log("Running TSP with numPoints:", numPoints); // Before running TSP
                const result = tspModule.runTSP(numPoints);
                console.log("TSP computation finished with result:", result); // After running TSP
                self.postMessage({ action: 'tspResult', result: result });
            } catch (error) {
                console.error("Error running TSP:", error);
                self.postMessage({ action: 'tspError', message: error.message });
            }
        }
    });
}).catch((err) => {
    console.error("Failed to initialize the module:", err);
});
