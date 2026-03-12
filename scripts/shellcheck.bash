#!/usr/bin/env bash

exec shellcheck -s bash -x \
  home/.chezmoiscripts/*/*.sh* \
  scripts/*.bash
