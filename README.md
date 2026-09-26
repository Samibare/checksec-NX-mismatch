# checksec NX / PT_GNU_STACK divergence

**Finding:** On ELF binaries with multiple `PT_GNU_STACK` headers, checksec's NX
detection disagrees with the Linux kernel. The kernel honors the **last**
`PT_GNU_STACK`; 3 of 4 tested checksec builds do not, and report a
kernel-executable stack as "NX enabled" (false assurance).

**Upstream issue:** https://github.com/slimm609/checksec/issues/357
**Environment:** Ubuntu 26.04 LTS, kernel 7.0.0-31-generic

## Reproduce
```
git clone https://github.com/Samibare/checksec-NX-mismatch/tree/main
cd checksec-NX-mismatch
docker build -t checksec-nx .
docker run -rm checksec-nx ./run-sh
```
`run.sh` runs all four checksec builds against the crafted test cases and prints
the result matrix. Expected output: the divergence table below.

## Result

| Build | Algorithm | RW-RWE | RWE-RW | RW |
|---|---|---|---|---|
| Go main (269453e) | first match | False assurance | False alarm | OK |
| Go latest (71012bf) | any non-X | False assurance | OK | OK |
| Bash 2.6.0 (2753ebb) | any RWE | OK | False alarm | OK |
| Bash main (269453e) | metadata of first RW | False assurance | False alarm | OK |
| Linux kernel | last-wins | executable | non-exec | non-exec |

## Repository contents

- `src/` — C harness (`testNXChecksec.c`) that reports whether the stack is executable at runtime
- `bins/` — crafted test binaries (two `PT_GNU_STACK` headers; source in `src/`)
- `Dockerfile` — pins the environment and fetches the four checksec builds at their commits
- `run.sh` — runs all builds against all cases, prints the matrix

---

# Write-up
