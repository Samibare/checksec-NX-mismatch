#!/usr/bin/env bash
set -uo pipefail

echo "RW-RWE"
echo “Kernel: $(/nx-mismatch/bins/RW-RWE.out)”
echo “Go main (269453e) $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/RW-RWE.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “Go @latest (71012bf) $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/RW-RWE.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “bash main (269453e) $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/RW-RWE.out)”
echo “bash apt (2753ebb) $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/RW-RWE.out)”

echo "RWE-RW"
echo “Kernel: $(/nx-mismatch/bins/RWE-RW.out)”
echo “Go main (269453e) $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/RWE-RW.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “Go @latest (71012bf) $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/RWE-RW.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “bash main (269453e) $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/bash-RWE-RW.out)”
echo “bash apt (2753ebb) $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/RWE-RW.out)”

echo "E"
echo “Kernel: $(/nx-mismatch/bins/E.out)”
echo “Go main (269453e) $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/E.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “Go @latest (71012bf) $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/E.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “bash main (269453e) $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/E.out)”
echo “bash apt (2753ebb) $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/E.out)”

echo "R"
echo “Kernel: $(/nx-mismatch/bins/R.out)”
echo “Go main (269453e) $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/R.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “Go @latest (71012bf) $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/R.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “bash main (269453e) $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/R.out)”
echo “bash apt (2753ebb) $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/R.out)”

echo "W"
echo “Kernel: $(/nx-mismatch/bins/W.out)”
echo “Go main (269453e) $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/W.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “Go @latest (71012bf) $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/W.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “bash main (269453e) $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/W.out)”
echo “bash apt (2753ebb) $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/W.out)”

echo "RW"
echo “Kernel: $(/nx-mismatch/bins/RW.out)”
echo “Go main (269453e) $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/RW.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “Go @latest (71012bf) $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/RW.out) | grep NX | tail -1 | awk '{print $8, $9}'
”
echo “bash main (269453e) $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/RW.out)”
echo “bash apt (2753ebb) $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/RW.out)”
