#!/bin/bash
#
# Counts the entries in each directory

for f in * ; do echo -e $f":\t"$(ls $f | wc -l); done
