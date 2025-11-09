/**
 * StartOS Procedure Exports - Garbageman Nodes Manager
 * 
 * This file exports all StartOS SDK procedures that define how the service
 * integrates with the StartOS platform. These procedures are bundled into
 * embassy.js during the build process.
 * 
 * Exported procedures:
 * - setConfig: Apply new configuration from StartOS UI
 * - getConfig: Retrieve current configuration
 * - properties: Display dynamic service properties
 * - migration: Handle version upgrade migrations
 * - health: Perform health checks
 */

export { setConfig } from "./procedures/setConfig.ts";
export { getConfig } from "./procedures/getConfig.ts";
export { properties } from "./procedures/properties.ts";
export { migration } from "./procedures/migrations.ts";
export { health } from "./procedures/healthChecks.ts";
