#!/bin/sh

echo "\\newglossaryentry{$1}{%"
echo "    name        = {$1},%"
echo "    description = {}%"
echo "}"
