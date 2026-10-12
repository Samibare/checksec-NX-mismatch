# checksec NX / PT_GNU_STACK divergence

**Finding:** On crafted ELF binaries, checksec's NX detection diverges from the Linux kernel. The kernel honors the **last** `PT_GNU_STACK`'s execute bit `PF_X`. Across multiple header and non standard flag cases, all four tested builds report a kernel executable stack as "NX enabled" (false assurance) in at least one of the cases.

**Upstream issue:** https://github.com/slimm609/checksec/issues/357

**Environment:** Ubuntu 26.04 LTS, kernel 7.0.0-31-generic

## Reproduce
```
git clone https://github.com/Samibare/checksec-NX-mismatch.git
cd checksec-NX-mismatch
docker build -t checksec-nx .
docker run --rm checksec-nx ./runByBuild.sh 
docker run --rm checksec-nx ./runByTest.sh 
```
`runByBuild.sh` runs all four checksec builds against the crafted test cases by build and prints
the result. `runByTest.sh` runs all four checksec builds against the crafted test cases by test file and prints
the result. Expected output: the same result as the divergence table below.

## Result

| Build | Algorithm | RW-RWE | RWE-RW | __E | \_W\_ & R\_\_ | RW |
|---|---|---|---|---|---|---|
| Go main (269453e) | first match | False assurance | False alarm | OK | OK | OK |
| Go latest (71012bf) | any non-X | False assurance | OK | OK | OK | OK |
| Bash 2.6.0 (2753ebb) | any RWE | OK | False alarm | False assurance | OK | OK |
| Bash main (269453e) | metadata of first RW | False assurance | False alarm | OK | False alarm | OK |
| Linux kernel | last-wins | executable | non-exec | executable | non-exec | non-exec |

## Repository contents

- `src/` - C harness (`testNXChecksec.c`) that reports whether the stack is executable at runtime
- `bins/` - crafted test binaries (two `PT_GNU_STACK` headers; source in `src/`)
- `Dockerfile` - pins the environment and fetches the four checksec builds at their commits
- `runByBuild.sh` - runs all builds against all cases
- `runByTest.sh` - runs all test cases against builds

---

# Write-up

**Abstract:**
Checksec reports the security posture of an ELF binary by inspecting the ELF metadata corresponding to mitigations enforced by the kernel or dynamic loader. Checksec also uses this reported mitigation posture to provide exploitability reasoning, including identifying attack techniques a binary’s mitigations fail to obstruct. Therefore, its correctness affects not only what a user reads but also what downstream reasoning consumes. This work examines the correctness of NX mitigation reporting by checksec compared to runtime behavior when there are multiple `PT_GNU_STACK` headers and non standard flag cases. Using a crafted ELF binary whose runtime stack executability serves as ground truth, four checksec builds were tested (Bash 2.6.0, Go @latest (commit 71012bf), Go main (commit 269453e), and Bash main (commit 269453e)). None reproduced the kernel’s last-wins rule. Each implemented a different algorithm (first match, any non-executable, any RWE, and metadata of the first RW), and all builds produced at least one false assurance across crafted test cases. These divergences indicate that checksec’s NX check is not derived from the kernel’s loader semantics. Notably, the four builds implement four different algorithms; the check has been reimplemented and rederived four different times rather than converging on the loader’s actual behavior.

**Background:**  
So what is PT\_GNU\_STACK? To start, an ELF file has multiple program headers (PTs) that the kernel processes and interprets to determine certain program behavior. PT\_GNU\_STACK is one of the possible PTs that an ELF file has, and it determines whether the stack is executable or not. The mitigation of making the stack non-executable is referred to as NX (**N**on-e**X**ecutable). Ultimately, PT\_GNU\_STACK determines the posture of NX mitigation of a file.

How does the kernel process the PT\_GNU\_STACK header? More importantly, how does it determine the state of NX when there are multiple PT\_GNU\_STACK headers? The kernel iterates through all PT\_GNU\_STACK headers and updates the state of NX. This results in the last PT\_GNU\_STACK winning, utilizing the value of the flag it holds.

What does checksec report? Checksec reports the security posture of a program; one of them is NX. If checksec derives that NX is present on a binary, it will report “NX enabled” and “NX disabled” otherwise.

Why does this matter? Checksec provides exploitability reasoning based on the reported mitigation posture, including reasoning about which attack techniques a binary's mitigations fail to obstruct. A user may rely on checksec’s output when assessing exploitability; any mismatches between the kernel and checksec can lead to incorrect conclusions about a binary’s security and exploitability. This also creates a risk for users who rely on checksec to verify a binary’s security posture before deploying or trusting it.

**Premise:**  
Checksec is designed to analyze ELF binaries and report their security posture, including mitigation status and higher-level exploitability reasoning about which attack techniques a binary’s mitigations fail to obstruct. It can also output in an LLM-oriented format for direct consumption by an LLM. Therefore, crafted ELF binaries remain relevant inputs when evaluating the correctness and reliability of checksec analysis. In particular, if checksec reports an NX state that differs from the state enforced by the Linux kernel, its analysis may be based on an incorrect mitigation state, potentially leading to misleading conclusions about the binary's security posture or exploitability.

Source: [https://slimm609.github.io/checksec/](https://slimm609.github.io/checksec/)  
“Beyond reporting the raw mitigation posture, checksec can reason about which attack techniques that posture fails to obstruct ([exploitability reasoning](https://slimm609.github.io/checksec/checks/exploitability/), \--exploit) and emit a self-grounding report you can paste straight into an LLM ([\-o llm](https://slimm609.github.io/checksec/llm/)).”

**Research Question:**  
Does checksec’s NX detection reproduce the Linux kernel’s behavior for ELF binaries with non standard `PT_GNU_STACK` configurations: specifically multiple headers and non standard flag values?

**Method:**  
The program checks whether the stack is executable by placing an instruction on the stack and calling the stack. This “function” on the stack will return the integer 50 when called. The program then calls the loaded function on the stack and checks whether it returned 50\. If the function returns 50, then it prints “Stack is executable”. However, when the process crashes, the program catches it and prints “Stack is not executable”

This C program is then compiled into a binary. I then modified the binary through hexedit and replaced a `PT_NOTE` header with a `PT_GNU_STACK` header, resulting in two `PT_GNU_STACK` headers. From here, I created 2 versions of multi header ELF binary's. RW-RWE will have the first `PT_GNU_STACK` flag set to 0x6 (`RW_`) and the second flag to 0x7 (`RWE`). RWE-RW will have the first flag set to 0x7 (`RWE`) and the second to 0x6 (`RW_`). I also made a single header ELF binary with non-standard value. \_\_E will have a single `PT_GNU_STACK` where the value of the flag is 0x1 (`__E`). Similarly, I also made \_W\_ and R\_\_ test binary as well. Additionally, I made a ELF binary that has the default configuration for stack mitigation. RW will be the unmodified version, with one `PT_GNU_STACK` and the flag set to 0x6 (The default GCC compiling behavior). All binaries’ `PT_GNU_STACK` will have the fields zeroed out.

**Kernel behavior:**  
The kernel’s behavior will be the reference that checksec’s different builds will be compared to.

The Kernel continuously iterates through the entire program header and updates the flag for every PT\_GNU\_STACK it encounters. This results in the last `PT_GNU_STACK`’s flag being utilized.

\$ uname \-r  
7.0.0-31-generic

linux/fs/binfmt\_elf.c, function load\_elf\_binary, the PT\_GNU\_STACK case, at commit 028ef9c.  
This is v7.0, matching the 7.0 kernel shipped in Ubuntu 26.04  
[https://github.com/torvalds/linux/blob/028ef9c96e96197026887c0f092424679298aae8/fs/binfmt\_elf.c\#L939-L956](https://github.com/torvalds/linux/blob/028ef9c96e96197026887c0f092424679298aae8/fs/binfmt_elf.c#L939-L956)

This logic is present unchanged from at least v5.0 through v7.0. Commit 1c163f4 is for v5.0  
[https://github.com/torvalds/linux/blob/1c163f4c7b3f621efff9b28a47abb36f7378d783/fs/binfmt\_elf.c\#L807C1-L825C1](https://github.com/torvalds/linux/blob/1c163f4c7b3f621efff9b28a47abb36f7378d783/fs/binfmt_elf.c#L807C1-L825C1)

**NX check logic and divergence matrix:**
Each checksec build determines the binary's NX posture differently. Each section covers one build of checksec, describing the algorithm and the divergence between the output and runtime behavior. 

Definitions:

- False assurance: When checksec claims that NX is enabled, but runtime has it disabled.  
- False alarm: When checksec claims that NX is disabled, but runtime has it enabled  
- No mismatch: When both checksec and runtime agree on the NX posture.

---

The current version of main for Go conducts the NX check through the first-match algorithm and reports based off of `PF_X` value of the first `PT_GNU_STACK`. This results in accurate reporting on ELF file that has single `PT_GNU_STACK` header, but incorrect reporting when there are multiple. 

| Checksec GO (main, 269453e): First match |  |  |  |  |  |
| :---- | :---- | :---- | :---- | :---- | :---- |
| GNU\_STACK flags (1st \- 2nd) | RW-RWE | RWE-RW | __E | \_W\_ & R\_\_ | RW |
| Checksec GO | NX enabled | NX disabled | NX disabled | NX enabled | NX enabled |
| Kernel/Run time | Stack executable | Stack non-executable | Stack executable | Stack non-executable | Stack non-executable |
| Mismatch | False assurance | False alarm | No mismatch | No mismatch | No mismatch |

checksec/pkg/checksec/[nx.go](http://nx.go), function NX, PT\_GNU\_STACK check, at commit 269453e and introduced in commit c14b768.  
[https://github.com/slimm609/checksec/blob/269453e091f196741d7c521da09a1e779870fee4/pkg/checksec/nx.go\#L22-L36](https://github.com/slimm609/checksec/blob/269453e091f196741d7c521da09a1e779870fee4/pkg/checksec/nx.go#L22-L36)

---

The latest checksec build is available through 

go install github.com/slimm609/checksec@latest

At the time of writing this, 9/15/2026, the build provided by checksec@latest is commit 71012bf5cee9. This build conducts the NX check with any non-X algorithm. The presence of a single `PT_GNU_STACK` without the execute bit set on the flag will cause the algorithm to return that NX is enabled, causing a bias towards flagging the binary as NX-enabled. It therefore never produces a false alarm, but it still produces false assurance. As a side note, the algorithm correctly outputs the state of NX when their is one `PT_GNU_STACK`, while reporting may be inaccurate when there are multiple.

| Checksec go (Commit @71012bf): Any non-X |  |  |  |  |  |
| :---- | :---- | :---- | :---- | :---- | :---- |
| GNU\_STACK flags (1st \- 2nd) | RW-RWE | RWE-RW | __E | \_W\_ & R\_\_ | RW |
| Checksec Go commit 71012bf5cee9   | NX enabled | NX enabled | NX disabled | NX enabled | NX enabled |
| Kernel/Run time | Stack executable | Stack non-executable | Stack executable | Stack non-executable | Stack non-executable |
| Mismatch | False assurance | No mismatch | No mismatch | No mismatch | No mismatch |

checksec/pkg/checksec/nx.go, function NX(), PT\_GNU\_STACK check, at commit 71012bf  
[https://github.com/slimm609/checksec/blob/71012bf5cee95e46c120cbfa9afa0520ac2c5573/pkg/checksec/nx.go\#L19-L25](https://github.com/slimm609/checksec/blob/71012bf5cee95e46c120cbfa9afa0520ac2c5573/pkg/checksec/nx.go#L19-L25)

---

The checksec bash build v2.6.0 is installable through 

sudo apt update   
sudo apt install checksec

conducts the NX check by grepping all `PT_GNU_STACK` program headers, then grepping for any `RWE` flag. If there is any `RWE` flag, it will return NX disabled; otherwise, it will return NX enabled.

However, as the algorithm only checks if there are any `RWE` flag values, if the flag values are anything other than `RWE`, it will report that NX is enabled. With this, we can cause a false assurance with a single `PT_GNU_STACK` header by setting the flag to any executable but not `RWE` value (`__E`, `_WE`, or `R_E`). I verified this with `__E`; the other two follow from the same mechanism, since the check matches only the literal string `RWE`.

| Checksec bash (2.6.0, @2753ebb): Any RWE |  |  |  |  |  |
| :---- | :---- | :---- | :---- | :---- | :---- |
| GNU\_STACK flags (1st \- 2nd) | RW-RWE | RWE-RW | __E | \_W\_ & R\_\_ | RW |
| Checksec bash 2.6.0 | NX disabled | NX disabled | NX enabled | NX enabled | NX enabled |
| Kernel/Run time | Stack executable | Stack non-executable | Stack executable | Stack non-executable | Stack non-executable |
| Mismatch | No mismatch | False alarm | False assurance | No mismatch | No mismatch |

‘apt policy checksec’ produces  
checksec:  
  Installed: 2.6.0-2build1  
  Candidate: 2.6.0-2build1  
  Version table:  
 \*\*\* 2.6.0-2build1 500  
        500 http://us.archive.ubuntu.com/ubuntu resolute/universe amd64 Packages  
        100 /var/lib/dpkg/status

Any `RWE` logic in filecheck() and proccheck(). Ubuntu 2.6.0-2build1 (26.04 resolute/universe) ships upstream checksec 2.6.0 unpatched. Verified through apt-get source not containing debian/patches, indicating an empty patches series. The logic is identical to upstream tag 2.6.0.  
filecheck():	[https://github.com/slimm609/checksec/blob/2753ebb89fcdc96433ae8a4c4e5a49214a845be2/checksec\#L720C2-L729C5](https://github.com/slimm609/checksec/blob/2753ebb89fcdc96433ae8a4c4e5a49214a845be2/checksec#L720C2-L729C5)  
proccheck():	[https://github.com/slimm609/checksec/blob/2753ebb89fcdc96433ae8a4c4e5a49214a845be2/checksec\#L1553-L1577](https://github.com/slimm609/checksec/blob/2753ebb89fcdc96433ae8a4c4e5a49214a845be2/checksec#L1553-L1577)

---

The main version of bash determines the posture of NX by analyzing the metadata of the first `PT_GNU_STACK` that has an RW flag value. If the metadata is all zeros, it reports that NX is enabled; otherwise, NX is disabled. Additionally, if  `PT_GNU_STACK` that has RW flag value is not present, it defaults to reporting as NX is disabled. This causes false alarm through `_W_` or `R__` flag value.

Due to the algorithm relying on the value of fields, to display the mismatch `RWE-RW.out` has been modified to make `bash-RWE-RW.out`. Both `PT_GNU_STACK` headers in `RWE-RW.out` have zeroed-out metadata/fields; However, `bash-RWE-RW.out` test binary has a offset value of 0x1 for the `PT_GNU_STACK` header with flag value of RW.

| Checksec bash (main, 269453e): Checks the metadata of the first PT\_GNU\_STACK with RW flag value |  |  |  |  |  |
| :---- | :---- | :---- | :---- | :---- | :---- |
| GNU\_STACK flags (1st \- 2nd) | RW-RWE (Both fields zeroed out) | RWE-RW (RW offset field \= 0x1) | __E | \_W\_ & R\_\_ | RW |
| Checksec bash main | NX enabled | NX disabled | NX disabled | NX disabled | NX enabled |
| Kernel/Run time | Stack executable | Stack non-executable | Stack executable | Stack non-executable | Stack non-executable |
| Mismatch | False assurance | False alarm | No mismatch | False alarm | No mismatch |

checksec/checksec.bash, function filecheck(), GNU\_STACK check, at commit 269453e [https://github.com/slimm609/checksec/blob/269453e091f196741d7c521da09a1e779870fee4/checksec.bash\#L730-L740](https://github.com/slimm609/checksec/blob/269453e091f196741d7c521da09a1e779870fee4/checksec.bash#L730-L740)

---

As shown at the beginning, the following is a compacted summary of all checksec builds tested and their results


| Build | Algorithm | RW-RWE | RWE-RW | __E | \_W\_ & R\_\_ | RW |
|---|---|---|---|---|---|---|
| Go main ([269453e](https://github.com/slimm609/checksec/blob/269453e091f196741d7c521da09a1e779870fee4/pkg/checksec/nx.go#L22-L36)) | first match | False assurance | False alarm | OK | OK | OK |
| Go latest ([71012bf](https://github.com/slimm609/checksec/blob/71012bf5cee95e46c120cbfa9afa0520ac2c5573/pkg/checksec/nx.go#L19-L25)) | any non-X | False assurance | OK | OK | OK | OK |
| Bash 2.6.0 ([2753ebb](https://github.com/slimm609/checksec/blob/2753ebb89fcdc96433ae8a4c4e5a49214a845be2/checksec#L720C2-L729C5)) | any RWE | OK | False alarm | False assurance | OK | OK |
| Bash main ([269453e](https://github.com/slimm609/checksec/blob/269453e091f196741d7c521da09a1e779870fee4/checksec.bash#L730-L740)) | metadata of first RW | False assurance | False alarm | OK | False alarm | OK |
| Linux kernel | last-wins | executable | non-exec | executable | non-exec | non-exec |

**Synthesis:**  
Of the four checksec builds, three of them produced false assurance on `RW-RWE` (Go main, Bash main, and Go latest). The bash build 2.6.0, installable through the current apt, produces false assurance when the effective `PT_GNU_STACK` has executable bit set but is not the literal `RWE` (as described above), and no `PT_GNU_STACK` has the flag value of `RWE` if their are multiple `PT_GNU_STACK` headers. The false assurance also occurs even with a single header. None of the builds replicate the kernel's last-wins behavior. 

With all 4 builds having different algorithm from one another, and none replicating the kernel's  behavior of using the last `PT_GNU_STACK` headers `PF_X` value, there is a clear disconnect between checksec’s NX logic and the kernel’s actual ELF loading behavior. 

**Prior art review:**
Issue \#132 \[NX stack checking is incomplete\]  
Lack of checking the size of the stack segment. “A non-zero size indicates an executable stack”

This is different from the issue I am flagging (Flaw in validation algorithm), as this points out a flaw in the lack of consideration for how the kernel handles PT\_GNU\_STACK.

---

Issue \#161 \[RELRO Checking is incorrect for crafted ELF file\]

This highlights a mismatch in the checksec and runtime behavior for RELRO on a crafted ELF file. While in a different scope, this has a similar methodology to fool checksec by modifying an ELF file.

Additionally, user disconnect3d also mentions that it is possible to fool the stack canary check through compiling 
`
void lol__stack_chk_fail() {}  
int main() {  
    lol__stack_chk_fail();  
}
`
While user Maryse47 questions whether checking a troll code is in the scope of checksec, the said troll code (Pointing to any ELF file intentionally crafted to deceive checksec) is extremely plausible to find in environments such as CTFs. A CTF player may rely on checksec to determine the security posture of a binary to narrow down the exploitation scope. Any false signal will result in a negative outcome where the player may spend unnecessary time, as they worked on the assumption that checksec was correct and overlooked any mitigation being turned off.

However, user disconnect3d counters this by mentioning that “checksec is often used for random binaries and to make statements of platform security,” and that it's plausible to have a vulnerable binary slip in.

This issue resulted in the author accepting and resolving it in the main branch. Because the maintainer accepted and fixed \#161, despite the “troll code” objection, crafted ELF false assurance in a file check is in scope by the maintainer's own revealed decision. This report describes an unfixed instance of that same class, not a request to expand scope.

**Root cause and the fix:**

The cause of the mismatch between the runtime behavior and the checksec stems from the difference in the checking algorithm. The checksec evaluates the posture of NX through selecting `PT_GNU_STACK` by its own algorithm, instead of the last one the loader honors. 

The underlying issue is that checksec re-derives the NX rule instead of mirroring load\_elf\_binary. To prevent any similar bugs in the future, it is suggested to mirror the kernel/loader’s behavior.

Scope of fix:  
The false assurance defect exists in Go builds and the current bash build in main@269453e. As the current main@269453e supersedes the older version (bash 2.6.0 and Go latest @71012bf), I will be scoping the fix to Go main and bash main.

Go main @269453e fix:  
The fix for this is to remove the `break` inside the if statement. This allows the loop to retain the last GNU\_STACK flag rather than the first, matching the kernel's last-wins behavior.

This allows the Go script to iterate through the entire `PT_GNU_STACK` header and continues with the last flag value, rather than using the first one it encounters. This stays consistent with kernel's `PT_GNU_STACK` semantics.
https://github.com/slimm609/checksec/blob/269453e091f196741d7c521da09a1e779870fee4/pkg/checksec/nx.go#L34

Bash main @269453e fix:  
The fix for this is to rework how the bash script handles `PT_GNU_STACK`. The bash script needs to drop the precondition that the metadata must equal 0, and inspect only the last `PT_GNU_STACK` entry to replicate the kernel’s last-wins behavior.  
```
readelf -lW "${1}" 2>/dev/null | grep 'GNU_STACK' | tail -1 | grep -q 'E'
```
This line selects the last GNU\_STACK header and checks for `E`. If `E` is present, the command returns true; otherwise, it returns false. This fix works because `readelf` preserves the program header ordering. Additionally, hexadecimal values containing `0xe` are displayed in lowercase, while the permission flags are uppercase. This fix also accounts for `_W_` and `R__` false alarm, since it only checks for the execute bit for the last `PT_GNU_STACK`.

This is a minimal, drop-in change consistent with the current readelf-based implementation. Parsing the program header directly would be more robust.
https://github.com/slimm609/checksec/blob/269453e091f196741d7c521da09a1e779870fee4/checksec.bash#L733

**Conclusion:**  
Across four checksec builds, none replicated the Linux kernel’s last PT\_GNU\_STACK semantics. Three produced false assurance for the RW-RWE test case, while the fourth, bash build 2.6.0, produced false assurance on the single header `__E` test case; reporting NX as enabled despite the runtime process having an executable stack. The mismatch originates from the NX detection algorithms selecting or misinterpreting PT\_GNU\_STACK entries differently from the kernel’s ELF loading logic.
