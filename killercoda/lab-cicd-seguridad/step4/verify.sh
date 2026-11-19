#!/bin/bash
curl -s localhost:30080/api/health | grep -q '"ok"'
