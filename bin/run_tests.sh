#!/usr/bin/env bash
spec/wait-for-it.sh overlord:8090 --timeout=30 --strict -- rspec
