/**
 * TypeScript Bundle Script - Garbageman Nodes Manager
 * 
 * This Deno script bundles all TypeScript procedures into a single embassy.js
 * file that StartOS can execute. The bundling process:
 * 1. Resolves all imports from embassy.ts
 * 2. Fetches remote dependencies (StartOS SDK)
 * 3. Transpiles TypeScript to JavaScript
 * 4. Outputs a single self-contained embassy.js file
 * 
 * This script is called by the Makefile during the package build process.
 * 
 * Usage: deno run --allow-read --allow-write --allow-env --allow-net bundle.ts
 */

import { bundle } from "emit";

const result = await bundle("scripts/embassy.ts");

await Deno.writeTextFile("scripts/embassy.js", result.code);
