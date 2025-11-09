/**
 * StartOS SDK Dependencies - Garbageman Nodes Manager
 * 
 * This file imports and re-exports the StartOS Embassy SDK, which provides
 * the types and utilities needed to implement service procedures.
 * 
 * SDK version: v0.3.3.0.11 (compatible with StartOS 0.3.5.x)
 * 
 * The SDK provides:
 * - Type definitions for config, properties, health checks, migrations
 * - Compat utilities for standard config operations
 * - Health check utilities (checkWebUrl, catchError)
 * - Effects system for safe side effects
 */

export * from "https://deno.land/x/embassyd_sdk@v0.3.3.0.11/mod.ts";
