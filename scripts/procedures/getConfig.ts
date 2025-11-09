/**
 * Configuration Retrieval - Garbageman Nodes Manager
 * 
 * This procedure retrieves the current service configuration from StartOS.
 */

import { compat, types as T } from "../deps.ts";

// Generate a random password using alphanumeric characters
function generateRandomPassword(length: number = 16): string {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let password = '';
  for (let i = 0; i < length; i++) {
    password += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return password;
}

export const getConfig: T.ExpectedExports.getConfig = compat.getConfig({
  "api-port": {
    type: "number",
    name: "API Port",
    description: "Internal port for the API server (Fastify backend)",
    nullable: false,
    range: "[1024,65535]",
    integral: true,
    default: 8080,
    warning: "Changing this port requires a service restart. Ensure it doesn't conflict with other services on your StartOS device.",
  },
  "ui-port": {
    type: "number",
    name: "UI Port",
    description: "Internal port for the web UI (Next.js frontend)",
    nullable: false,
    range: "[1024,65535]",
    integral: true,
    default: 5173,
    warning: "This is the internal port. External access is via Tor hidden service on port 80. Changing this requires a service restart.",
  },
  "supervisor-port": {
    type: "number",
    name: "Supervisor Port",
    description: "Internal port for the multi-daemon supervisor",
    nullable: false,
    range: "[1024,65535]",
    integral: true,
    default: 9000,
    warning: "The supervisor manages all Bitcoin daemon instances. Changing this port requires a service restart.",
  },
  "admin-password": {
    type: "string",
    name: "Admin Password",
    description: "Secure password for API access. This will be used for future authentication features. Store this securely.",
    nullable: false,
    masked: true,
    copyable: true,
    pattern: "[a-zA-Z0-9!@#$%^&*]+",
    "pattern-description": "Must contain letters, numbers, and special characters",
    default: generateRandomPassword(16),
    warning: "Changing the password does not retroactively invalidate existing sessions. For security, restart the service after changing this value.",
  },
  "log-level": {
    type: "enum",
    name: "Log Level",
    description: "Logging verbosity for all services (API, UI, Supervisor).\n- debug: Very verbose, useful for troubleshooting\n- info: Normal operation logs (recommended)\n- warn: Only warnings and errors\n- error: Only errors",
    values: ["debug", "info", "warn", "error"],
    "value-names": {
      debug: "Debug (Very Verbose)",
      info: "Info (Recommended)",
      warn: "Warnings Only",
      error: "Errors Only",
    },
    default: "info",
  },
  "enable-tor-proxy": {
    type: "boolean",
    name: "Enable Tor Proxy",
    description: "Enable internal Tor SOCKS5 proxy for discovering .onion Bitcoin peers. Disabling this will limit peer discovery to clearnet DNS seeds only.",
    default: true,
    warning: "Disabling Tor reduces privacy and limits peer discovery to clearnet nodes. Tor is recommended for best privacy.",
  },
  "max-instances": {
    type: "number",
    name: "Maximum Instances",
    description: "Maximum number of concurrent Bitcoin daemon instances allowed. Each instance requires ~10 GB RAM + 500 GB disk. Scale based on your available hardware resources.",
    nullable: false,
    range: "[1,50]",
    integral: true,
    units: "instances",
    default: 10,
    warning: "Running many instances simultaneously requires significant resources. Monitor your system's RAM and disk usage carefully. Each full Bitcoin node requires approximately 10 GB RAM and 500 GB disk space.",
  },
  advanced: {
    type: "object",
    name: "Advanced Settings",
    description: "Advanced configuration options for power users",
    spec: {
      "tor-proxy-host": {
        type: "string",
        name: "Tor Proxy Host",
        description: "Hostname or IP address of the Tor SOCKS5 proxy. Leave default unless using an external Tor service.",
        nullable: false,
        default: "127.0.0.1",
        placeholder: "127.0.0.1",
      },
      "tor-proxy-port": {
        type: "number",
        name: "Tor Proxy Port",
        description: "Port for the Tor SOCKS5 proxy",
        nullable: false,
        range: "[1024,65535]",
        integral: true,
        default: 9050,
      },
      "peer-discovery-interval": {
        type: "number",
        name: "Peer Discovery Interval",
        description: "How often to refresh the peer discovery list (in minutes). Lower values = more frequent updates but higher CPU usage.",
        nullable: false,
        range: "[5,1440]",
        integral: true,
        units: "minutes",
        default: 60,
      },
      "enable-libre-relay-detection": {
        type: "boolean",
        name: "Enable Libre Relay Detection",
        description: "Automatically detect and tag Libre Relay nodes during peer discovery. Libre Relay is a Bitcoin Core fork that removes spam filters.",
        default: true,
      },
      "artifact-cache-size": {
        type: "number",
        name: "Artifact Cache Size",
        description: "Maximum number of imported artifacts to keep cached. Older artifacts are automatically purged when this limit is reached. Set to 0 for unlimited.",
        nullable: false,
        range: "[0,100]",
        integral: true,
        units: "artifacts",
        default: 5,
        warning: "Artifacts can be very large (1-10 GB each). Monitor disk space carefully.",
      },
    },
  },
});
