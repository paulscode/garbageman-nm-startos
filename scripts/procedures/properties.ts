/**
 * Service Properties - Garbageman Nodes Manager
 * 
 * This procedure defines dynamic properties displayed in the StartOS UI
 * Properties tab. Uses compat.properties which automatically reads the config
 * and allows defining which properties to display.
 */

import { compat, types as T } from "../deps.ts";

export const properties: T.ExpectedExports.properties = compat.properties;
