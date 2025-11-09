/**
 * Configuration Application - Garbageman Nodes Manager
 * 
 * This procedure applies new configuration values when the user saves changes
 * in the StartOS UI Config section.
 */

import { compat, types as T } from "../deps.ts";

export const setConfig: T.ExpectedExports.setConfig = compat.setConfig;
