#!/usr/bin/env bash
set -uo pipefail

echo "RW-RWE"
echo "Kernel: $(/nx-mismatch/bins/RW-RWE.out)"
echo "Go main (269453e): $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/RW-RWE.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "Go @latest (71012bf): $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/RW-RWE.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "bash main (269453e): $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/RW-RWE.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"
echo "bash apt (2753ebb): $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/RW-RWE.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"

echo -e "\nRWE-RW"
echo "Kernel: $(/nx-mismatch/bins/RWE-RW.out)"
echo "Go main (269453e): $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/RWE-RW.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "Go @latest (71012bf): $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/RWE-RW.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "bash main (269453e): $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/bash-RWE-RW.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"
echo "bash apt (2753ebb): $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/RWE-RW.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"

echo -e "\nE"
echo "Kernel: $(/nx-mismatch/bins/E.out)"
echo "Go main (269453e): $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/E.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "Go @latest (71012bf): $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/E.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "bash main (269453e): $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/E.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"
echo "bash apt (2753ebb): $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/E.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"

echo -e "\nR"
echo "Kernel: $(/nx-mismatch/bins/R.out)"
echo "Go main (269453e): $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/R.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "Go @latest (71012bf): $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/R.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "bash main (269453e): $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/R.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"
echo "bash apt (2753ebb): $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/R.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"

echo -e "\nW"
echo "Kernel: $(/nx-mismatch/bins/W.out)"
echo "Go main (269453e): $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/W.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "Go @latest (71012bf): $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/W.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "bash main (269453e): $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/W.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"
echo "bash apt (2753ebb): $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/W.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"

echo -e "\nRW"
echo "Kernel: $(/nx-mismatch/bins/RW.out)"
echo "Go main (269453e): $(/usr/local/bin/checksec-Go-269453e file /nx-mismatch/bins/RW.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "Go @latest (71012bf): $(/usr/local/bin/checksec-Go-latest-71012bf file /nx-mismatch/bins/RW.out | grep NX | tail -1 | awk '{print $8, $9}')"
echo "bash main (269453e): $(/usr/local/bin/checksec-Bash-269453e --file=/nx-mismatch/bins/RW.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"
echo "bash apt (2753ebb): $(/usr/local/bin/checksec-Bash-apt-2753ebb --file=/nx-mismatch/bins/RW.out | sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' | grep NX | tail -1 | awk '{print $5, $6}')"
