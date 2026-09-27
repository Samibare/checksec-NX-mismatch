#!/usr/bin/env bash
set -uo pipefail

echo "Kernel run time behavior"
/nx-mismatch/bins/RW-RWE.out
/nx-mismatch/bins/RWE-RW.out
/nx-mismatch/bins/RW.out

echo "Go main (269453e)"
/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/RW-RWE.out
/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/RWE-RW.out
/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/RW.out

echo "Go @latest (71012bf)"
/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/RW-RWE.out
/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/RWE-RW.out
/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/RW.out

echo "bash main (269453e)"
/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/RW-RWE.out
/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/bash-RWE-RW.out
/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/RW.out

echo "bash apt (2753ebb)"
/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/RW-RWE.out
/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/RWE-RW.out
/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/RW.out
