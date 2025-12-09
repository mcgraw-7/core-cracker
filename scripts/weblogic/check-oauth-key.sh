#!/bin/bash
# Check OAuth Public Key - Dec 4, 2025 Cert Rotation
# Compares your local vbms_p2.properties OAuth key against the expected value

PROPS=~/dev/Oracle/Middleware/Oracle_Home/user_projects/domains/P2-DEV/lib/vbms_p2.properties
NEW="MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApJesCXe1p3NMluzOsQK51amiu+hfBXuwiUL59dS26mlVQS8rNoxc0Eu2xV3zGXZVE68vhC8utuGSPqNeJLDebZSe5YsKN4RWb7IinHppuL2Sz3XDAEWixi8Zp0NqinY7L8CL4rCLqXzeF95J1xbQcBGLU7LytrSzLZyHjqUasmTWWBcoIzKqV1bIRjIltb1WNP0nXwDgikmT78l5VUUN+wKviTQLWcafe6bmW4RzmuD2LNt/ap6tYO0cZvhqkfp0rkQitMn0RVsns7QRxf9UUVH6p0WQm9rsF1qGgyYoZVM3SP0QTW0ERQmGoRnigpQVA3+sdAmHrY+ez0+spDNxxQIDAQAB"
CURRENT=$(grep "vbms.security.oauth.publicKey" "$PROPS" 2>/dev/null | cut -d'=' -f2)

echo "Current: ${CURRENT:-NOT FOUND}"
echo "Expected: $NEW"
[ "$CURRENT" = "$NEW" ] && echo "STATUS: OK" || echo "STATUS: NEEDS UPDATE"
