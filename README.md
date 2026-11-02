This guide provides step-by-step instructions to reproduce **Task 3 (Exploitation & Binary Hardening)** and **Task 4 (AppArmor Confinement & MAC Audit Verification)** on a clean environment.

## 1. Task 3 — Binary Compilation, Exploit Verification & Hardening

Task 3 demonstrates control-flow hijacking (`ret2win`) against the unconfined `legacy_log_parser` binary via a buffer overflow vulnerability, followed by compiling, verifying, and testing the hardened `legacy_log_parser_fixed` binary.

### Step 1.1: Compile Binaries with Compiler Flags

Compile the vulnerable binary (disabled protections) and the fixed/hardened binary (full mitigations enabled):

```bash
cd ~/csce465-agentsec/hw3/src

# 1. Compile vulnerable binary (No canary, NX disabled, No PIE, Partial RELRO)
gcc -fno-stack-protector -z execstack -no-pie legacy_log_parser.c -o legacy_log_parser

# 2. Compile fixed/hardened binary (Full RELRO, Stack Canary, NX enabled, PIE enabled, Fortify Source)
gcc -O2 -fstack-protector-strong -D_FORTIFY_SOURCE=2 -Wl,-z,relro,-z,now -fPIE -pie legacy_log_parser_fixed.c -o legacy_log_parser_fixed
```

### Step 1.2: Verify Mitigations (`checksec`)

Verify that binary security mitigations are properly enabled using `checksec`:

```bash
checksec --file=legacy_log_parser
checksec --file=legacy_log_parser_fixed
```

**Expected `checksec` Output:**

```text
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH      Symbols         FORTIFY Fortified       Fortifiable     FILE
Partial RELRO   No canary found   NX disabled   No PIE          No RPATH   No RUNPATH   52 Symbols      No      0               5               legacy_log_parser
Full RELRO      Canary found      NX enabled    PIE enabled     No RPATH   No RUNPATH   48 Symbols      Yes     2               4               legacy_log_parser_fixed
```

### Step 1.3: Execute Task 3 Verification Test Suite

Copy the fixed binary to replace `legacy_log_parser` and run the automated verification script to test edge cases and exploit resilience on the fixed binary:

```bash
# Replace binary with fixed build for testing
cp src/legacy_log_parser_fixed src/legacy_log_parser

# Run test suite
bash ~/csce465-agentsec/hw3/tests/run_all_tests.sh
```

**Expected Test Suite Verification Output:**

```text
=========================================================
      CSCE 465/765 Task 3 Verification Test Suite
=========================================================
Test Case 1 (valid short input): PASS (Accepted)
Test Case 2 (exactly maximum allowed input): PASS (Accepted)
Test Case 3 (one byte over the limit): PASS (Safely Rejected)
Test Case 4 (missing file): PASS (Handled Error Gracefully)
Test Case 5 (original exploit payload): PASS (Safely Rejected)
=========================================================
```

## 2. Task 4 — AppArmor Mandatory Access Control (MAC)

Task 4 confines `legacy_log_parser` using an AppArmor profile to enforce least privilege, blocking unauthorized system file access and binary execution even when control flow is hijacked.

### Step 2.1: Setup User & Directories

Configure the target restricted environment and decoy file:

```bash
# Create target project structure
mkdir -p ~/csce465-agentsec/hw3/{src,inbox,markers,policy}
cd ~/csce465-agentsec/hw3

# Create dedicated low-privilege user
sudo useradd --system --create-home --shell /usr/sbin/nologin agentlab

# Create the protected decoy directory and file
sudo mkdir -p /opt/agentsec
sudo touch /opt/agentsec/decoy.txt

# Configure workspace permissions and ownership
sudo chown -R agentlab:agentlab ~/csce465-agentsec/hw3/inbox
sudo chown -R agentlab:agentlab ~/csce465-agentsec/hw3/markers
sudo chown -R agentlab:agentlab /opt/agentsec

chmod +x /home/$USER
chmod +x /home/$USER/csce465-agentsec
chmod +x /home/$USER/csce465-agentsec/hw3

sudo chmod 777 ~/csce465-agentsec/hw3/inbox
sudo chmod 777 ~/csce465-agentsec/hw3/markers
sudo chmod 600 /opt/agentsec/decoy.txt
```

### Step 2.2: Save the AppArmor Security Profile

Save the following profile configuration to `~/csce465-agentsec/hw3/policy/apparmor.profile`:

```apparmor
#include <tunables/global>

/home/username/csce465-agentsec/hw3/src/legacy_log_parser {
  #include <abstractions/base>

  # 1. Allow execution of the parser binary and dynamic libraries
  /home/username/csce465-agentsec/hw3/src/legacy_log_parser mr,
  /lib/x86_64-linux-gnu/*.so* mr,
  /lib64/ld-linux-x86-64.so.* mr,

  # 2. Allow reading log payloads from inbox
  /home/username/csce465-agentsec/hw3/inbox/*.log r,

  # 3. Allow writing only to markers directory
  /home/username/csce465-agentsec/hw3/markers/* rw,

  # 4. Explicitly audit and deny access attempts to decoy file
  audit deny /opt/agentsec/decoy.txt rwkl,

  # 5. Explicitly audit and deny execution of shells/external binaries
  audit deny /bin/** x,
  audit deny /usr/bin/** x,
  audit deny /sbin/** x,
  audit deny /usr/sbin/** x,
}
```

> **Note:** If running under a different user account, replace `username` in the profile path with the appropriate username.

### Step 2.3: Load Profile into Kernel Enforce Mode

```bash
# Copy policy to system AppArmor directory
sudo cp ~/csce465-agentsec/hw3/policy/apparmor.profile /etc/apparmor.d/home.username.csce465-agentsec.hw3.src.legacy_log_parser

# Reload profile into kernel enforcement mode
sudo apparmor_parser -r -W /etc/apparmor.d/home.usernamecsce465-agentsec.hw3.src.legacy_log_parser

# Verify active profile status
sudo aa-status | grep legacy_log_parser
```

**Expected Output:**

```text
   /home/username/csce465-agentsec/hw3/src/legacy_log_parser
```

### Step 2.4: Verify Confinement & Capture Denial Audit Logs

Execute an unauthorized access attempt inside the confined profile context using `aa-exec` under user `agentlab`:

```bash
# 1. Trigger security violation under confinement
sudo -u agentlab aa-exec -p /home/username/csce465-agentsec/hw3/src/legacy_log_parser cat /opt/agentsec/decoy.txt

# 2. Inspect kernel AVC denial logs
sudo dmesg | grep -i apparmor | tail -n 5
```

**Expected User-Space Terminal Output:**

```text
cat: /opt/agentsec/decoy.txt: Permission denied
```

**Expected Kernel Audit Log (`dmesg` Output):**

```text
audit: type=1400 audit(...): apparmor="DENIED" operation="open" class="file" profile="/home/username/csce465-agentsec/hw3/src/legacy_log_parser" name="/opt/agentsec/decoy.txt" pid=6060 comm="cat" requested_mask="r" denied_mask="r" fsuid=995 ouid=995
```

## 3. Verification Summary

* **Task 3 Verification:**
  1. `gcc` compilation flags enforce mitigations on `legacy_log_parser_fixed`.
  2. `checksec` confirms Full RELRO, Stack Canary, NX, and PIE enablement.
  3. `cp src/legacy_log_parser_fixed src/legacy_log_parser` enables running `run_all_tests.sh` to pass all 5 test cases.

* **Task 4 Verification:**
  1. `aa-status` confirms profile is active in enforcement mode.
  2. Prohibited operations fail with user-space `Permission denied`.
  3. Kernel audit log records `apparmor="DENIED"` events.

