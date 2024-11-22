#!/bin/sh
node --no-warnings ./node_modules/.bin/eslint -c eslint.config.cjs --fix .
