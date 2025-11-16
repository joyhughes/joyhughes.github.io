#!/bin/bash

echo "Starting post-dist processing for GitHub Pages deployment..."

# Find and process lux.js files (handle hashed versions)
LUX_FILE=$(find . -name "lux*.js" -type f | head -1)

if [ -n "$LUX_FILE" ]; then
    echo "Found lux file: $LUX_FILE"

    # Copy lux file to root as lux.js (removing hash)
    cp "$LUX_FILE" "./lux.js"
    echo "Copied $LUX_FILE to ./lux.js"

    # If there's an assets folder, also copy there
    if [ -d "assets" ]; then
        cp "$LUX_FILE" "./assets/lux.js"
        echo "Copied $LUX_FILE to ./assets/lux.js"
    fi
else
    echo "No lux.js file found"
fi

echo "Updating file references..."

# Update all references from "./src/lux.js" to "./lux.js" in HTML, JS, and other files
find . -type f \( -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.json" \) \
    -exec sed -i '' 's|"\./src/lux\.js"|"./lux.js"|g' {} \; \
    -exec sed -i '' "s|'\./src/lux\.js'|'./lux.js'|g" {} \;

echo "Updated ./src/lux.js references to ./lux.js"

# Update index.html with new asset references from dist folder
if [ -f "index.html" ]; then
    echo "Updating index.html asset references..."

    # Find the main JS file in assets
    MAIN_JS=$(find ./assets -name "index-*.js" -type f | head -1)
    if [ -n "$MAIN_JS" ]; then
        MAIN_JS_NAME=$(basename "$MAIN_JS")
        sed -i '' "s|src=\"./assets/index-[^\"]*\.js\"|src=\"./assets/$MAIN_JS_NAME\"|g" index.html
        echo "Updated main JS reference to $MAIN_JS_NAME"
    fi

    # Find the main CSS file in assets
    MAIN_CSS=$(find ./assets -name "index-*.css" -type f | head -1)
    if [ -n "$MAIN_CSS" ]; then
        MAIN_CSS_NAME=$(basename "$MAIN_CSS")
        sed -i '' "s|href=\"./assets/index-[^\"]*\.css\"|href=\"./assets/$MAIN_CSS_NAME\"|g" index.html
        echo "Updated main CSS reference to $MAIN_CSS_NAME"
    fi

    # Find the favicon/logo file in assets
    FAVICON_FILE=$(find ./assets -name "*logo*" -o -name "*favicon*" -o -name "*icon*" | head -1)
    if [ -n "$FAVICON_FILE" ]; then
        FAVICON_NAME=$(basename "$FAVICON_FILE")
        sed -i '' "s|href=\"./assets/[^\"]*\\.svg\"|href=\"./assets/$FAVICON_NAME\"|g" index.html
        echo "Updated favicon reference to $FAVICON_NAME"
    fi
fi

# Update any references to hashed lux files to just lux.js
if [ -n "$LUX_FILE" ] && [ "$LUX_FILE" != "./lux.js" ]; then
    LUX_BASENAME=$(basename "$LUX_FILE")
    find . -type f \( -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.json" \) \
        -exec sed -i '' "s|$LUX_BASENAME|lux.js|g" {} \;
    echo "Updated references from $LUX_BASENAME to lux.js"
fi

echo "File processing completed!"

# Clean up - remove dist folder if it exists (since files are now copied to root)
if [ -d "dist" ]; then
    echo "Cleaning up dist folder..."
    rm -rf dist
    echo "Removed dist folder"
fi