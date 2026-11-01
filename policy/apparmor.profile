#include <tunables/global>

/home/avaayyaduraitamu/csce465-agentsec/hw3/src/legacy_log_parser {
  #include <abstractions/base>

  # 1. Allow execution of the parser binary and shared dynamic libraries
  /home/avaayyaduraitamu/csce465-agentsec/hw3/src/legacy_log_parser mr,
  /lib/x86_64-linux-gnu/*.so* mr,
  /lib64/ld-linux-x86-64.so.* mr,

  # 2. Allow reading log payloads from inbox
  /home/avaayyaduraitamu/csce465-agentsec/hw3/inbox/*.log r,

  # 3. Allow writing only to markers
  /home/avaayyaduraitamu/csce465-agentsec/hw3/markers/* rw,

  # 4. Explicitly audit and deny access attempts to decoy file
  audit deny /opt/agentsec/decoy.txt rwkl,

  # 5. Explicitly audit and deny shell spawning and execution of external binaries
  audit deny /bin/** x,
  audit deny /usr/bin/** x,
  audit deny /sbin/** x,
  audit deny /usr/sbin/** x,
}
