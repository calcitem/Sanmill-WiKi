#!/bin/bash

git add .
git commit -m "Updated WiKi (markdown)"
git push origin HEAD:master
git push wiki HEAD:master
