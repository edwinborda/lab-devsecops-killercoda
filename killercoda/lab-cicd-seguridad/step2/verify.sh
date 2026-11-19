#!/bin/bash
curl -s localhost:9000/api/system/status | grep -q '"UP"' && [ -s /root/lab/.sonar-token ]
