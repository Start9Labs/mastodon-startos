import { compat, types as T } from "../deps.ts";

export const getConfig: T.ExpectedExports.getConfig = compat.getConfig({
    "tor-address": {
      "name": "Tor Address",
      "description": "The Tor address of the mastodon federation/client interface",
      "type": "pointer",
      "subtype": "package",
      "package-id": "mastodon",
      "target": "tor-address",
      "interface": "main"
    },
    "single-user-mode": {
      "type": "boolean",
      "name": "Single User Mode",
      "description": "If set to true, the front page of your Mastodon instance will always redirect to the first profile in the database, and additional registrations will be disabled. If set to false, the front page of your Mastodon instance will display a login/register page.",
      "warning": "Disabling Single User Mode does not automatically enable new registrations on your Mastodon instance. You can still control who can and cannot register on your instance inside the settings of your Mastodon admin portal. If you decide to disable Single User Mode and enable registrations, it is highly recommended that you also require approval of new registrants and limit the total number of users on your instance for performance reasons.",
      "default": true
    },
    "advanced": {
      "type": "object",
      "name": "Advanced",
//      "nullable": false,
      "spec": {
        "smtp": {
          "type": "union",
          "name": "SMTP Settings",
          "description": "Configuration for sending emails.",
          "tag": {
            "id": "enabled",
            "name": "Enabled",
            "variant-names": {
              "true": "True",
              "false": "False"
            }
          },
          "default": "false",
          "variants": {
            "true": {
              "address": {
                "type": "string",
                "name": "Server Address",
                "description": "The fully qualified domain name of your SMTP server",
                "nullable": false
              },
              "port": {
                "type": "number",
                "name": "Port",
                "description": "The TCP port of your SMTP server",
                "default": 25,
                "integral": true,
                "range": "[0,65535]",
                "nullable": false
              },
              "from-address": {
                "type": "string",
                "name": "From Address",
                "description": "Email address to use as the \"from\" field of emails sent by mastodon",
                "nullable": false
              },
              "domain": {
                "type": "string",
                "name": "Domain",
                "description": "The domain to use for HELO",
                "nullable": true
              },
              "authentication": {
                "type": "union",
                "name": "Authentication",
                "description": "Settings for authenticating to your SMTP server",
                "tag": {
                  "id": "type",
                  "name": "Type",
                  "variant-names": {
                    "none": "None",
                    "plain": "Plain",
                    "login": "Login",
                    "cram-md5": "CRAM MD5"
                  }
                },
                "default": "none",
                "variants": {
                  "none": {},
                  "plain": {
                    "username": {
                      "type": "string",
                      "name": "Username",
                      "description": "The username for logging into your SMTP server",
                      "nullable": true
                    },
                    "password": {
                      "type": "string",
                      "name": "Password",
                      "description": "The password for logging into your SMTP server",
                      "nullable": true
                    }
                  },
                  "login": {
                    "username": {
                      "type": "string",
                      "name": "Username",
                      "description": "The username for logging into your SMTP server",
                      "nullable": true
                    },
                    "password": {
                      "type": "string",
                      "name": "Password",
                      "description": "The password for logging into your SMTP server",
                      "nullable": true
                    }
                  },
                  "cram-md5": {
                    "username": {
                      "type": "string",
                      "name": "Username",
                      "description": "The username for logging into your SMTP server",
                      "nullable": true
                    },
                    "password": {
                      "type": "string",
                      "name": "Password",
                      "description": "The password for logging into your SMTP server",
                      "nullable": true
                    }
                  }
                }
              },
              "enable-starttls-auto": {
                "type": "boolean",
                "name": "Enable STARTTLS Automatically",
                "description": "Detects if STARTTLS is enabled in your SMTP server and starts to use it",
                "default": true
              },
              "ssl": {
                "type": "union",
                "name": "SSL",
                "description": "Enables the SMTP connection to use SMTP/TLS",
                "tag": {
                  "id": "enable",
                  "name": "Enable",
                  "variant-names": {
                    "true": "True",
                    "false": "False"
                  }
                },
                "default": "true",
                "variants": {
                  "true": {
                    "openssl-verify-mode": {
                      "type": "enum",
                      "name": "OpenSSL Verify Mode",
                      "description": "When using TLS, you can set how OpenSSL checks the certificate.\nThis is really useful if you need to validate a self-signed and/or a wildcard certificate\n",
                      "values": [
                        "none",
                        "peer"
                      ],
                      "value-names": {
                        "none": "None",
                        "peer": "Peer"
                      },
                      "default": "none"
                    }
                  },
                  "false": {}
                }
              }
            },
            "false": {}
          }
        }
      }
    }
  });
