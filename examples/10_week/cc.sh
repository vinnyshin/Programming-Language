#!/bin/bash
set -x
g++ --std=c++17 $1
./a.out
rm a.out
