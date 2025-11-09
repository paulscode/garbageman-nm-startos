/**
 * Health Checks - Garbageman Nodes Manager
 * 
 * This procedure performs health checks to verify the service is running correctly.
 * Health checks run periodically and their status is displayed in the StartOS UI.
 * 
 * Current health checks:
 * - web-ui: Verifies the Next.js web interface is accessible and responding
 * 
 * The health check connects to the internal service hostname (garbageman-nm.embassy)
 * on port 5173 (default UI port, configurable via config).
 * 
 * Future health checks could verify:
 * - API server responsiveness
 * - Supervisor process health
 * - Running daemon instance count
 * - Blockchain sync status
 */

import { types as T, healthUtil } from "../deps.ts";

export const health: T.ExpectedExports.health = {
  async "web-ui"(effects: T.Effects, duration: number) {
    // Check the Garbageman web UI is accessible
    // Internal service name: garbageman-nm.embassy
    // Port: 5173 (default, configurable in config_spec.yaml)
    return await healthUtil.checkWebUrl("http://garbageman-nm.embassy:5173")(effects, duration)
      .catch(healthUtil.catchError(effects));
  },
};
