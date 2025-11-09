/**
 * Version Migrations - Garbageman Nodes Manager
 * 
 * This procedure handles data migrations when upgrading between service versions.
 * Migrations run automatically during package updates to transform configuration
 * and data structures as needed.
 * 
 * Current version: 0.1.0.1 (initial release)
 * 
 * The empty mapping ({}) indicates no migrations are defined yet since this is
 * the first version. Future versions can add migration logic here to handle:
 * - Configuration schema changes
 * - Data directory restructuring
 * - Compatibility updates
 * 
 * Example for future versions:
 *   .fromMapping({ 
 *     "0.1.0.1": { up: async (effects) => { ... }, down: async (effects) => { ... } }
 *   }, "0.2.0.0")
 */

import { compat, types as T } from "../deps.ts";

export const migration: T.ExpectedExports.migration = compat.migrations
    .fromMapping({}, "0.1.0.1");
