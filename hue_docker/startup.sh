#!/bin/sh

./build/env/bin/hue migrate
exec ./build/env/bin/supervisor --log-dir /tmp
