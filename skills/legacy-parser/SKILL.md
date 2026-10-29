---
name: legacy-parser
description: Runs a local legacy log parser on files located inside the HW3 inbox directory.
---

# Legacy Log Parser

This skill allows the agent to analyze log files using the legacy_log_parser program
developed for CSCE 465 HW3.

## Usage

The skill accepts one file path located under:

~/csce465-agentsec/hw3/inbox/

To execute the parser, run:

bash ~/csce465-agentsec/hw3/skills/legacy-parser/run_parser.sh <file_path>

## Restrictions

- Only files inside the HW3 inbox directory are permitted.
- Do not run the parser on files outside the inbox directory.
- Do not modify or delete input files.
- Use this skill only when log parsing is requested by the user.
