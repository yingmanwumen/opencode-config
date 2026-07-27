---
name: security-review
description: 'Perform an evidence-based security review of a repository or selected files. Use when asked to audit code, find vulnerabilities, inspect SQL injection, XSS, command injection, exposed secrets, dependency risks, authentication or access-control flaws, weak cryptography, or business-logic security issues. Combines repository inspection, available ecosystem audit tools, and cross-file reasoning; never presents unverified guesses as confirmed vulnerabilities.'
---

# Security Review

Perform a static, evidence-based review. Trace data flows and component interactions when
the repository provides enough context, but do not claim that this workflow replaces a
DAST, penetration test, dependency database, or runtime security monitoring.

## Evidence and Tool Boundaries

- Separate confirmed findings, likely findings, and review notes. A suspicious pattern is
  not a vulnerability until the relevant source, sink, trust boundary, and mitigation have
  been checked.
- Use repository-native audit commands when available (`npm audit`, `pnpm audit`,
  `pip-audit`, `bundle audit`, `cargo audit`, `govulncheck`, or the ecosystem equivalent).
  Do not invent CVE IDs, affected ranges, or remediation versions.
- If an audit tool, network, lockfile, or credential is unavailable, report the audit as
  `not run` or `incomplete` and state the exact reason. The package watchlist is only a
  heuristic for manual review, not proof of a current vulnerability.
- Do not print, reproduce, or include complete secrets. Redact values, for example as
  `sk_live_...abcd`, and report only the file, line, type, and remediation.
- Do not modify files, rotate credentials, rewrite git history, install packages, or run
  destructive commands unless the user explicitly requests and authorizes that action.

## When to Use This Skill

Use this skill when the request involves:

- Scanning a codebase or file for security vulnerabilities
- Running a security review or vulnerability check
- Checking for SQL injection, XSS, command injection, or other injection flaws
- Finding exposed API keys, hardcoded secrets, or credentials in code
- Auditing dependencies for known CVEs
- Reviewing authentication, authorization, or access control logic
- Detecting insecure cryptography or weak randomness
- Performing a data flow analysis to trace user input to dangerous sinks
- Any request phrasing like "is my code secure?", "scan this file", or "check my repo for vulnerabilities"
- Running `/security-review` or `/security-review <path>`

## Review Method

1. Establish scope, languages, frameworks, entrypoints, and available lockfiles.
2. Run only safe, read-only dependency and secret checks available in the environment;
   record command status and limitations.
3. Inspect source and configuration for vulnerability classes relevant to the stack.
4. Trace high-risk inputs to sinks across files where the call path is available.
5. Re-check each candidate against validation, encoding, authorization, middleware, and
   deployment configuration before assigning a severity.
6. Report findings with confidence and evidence. Include proposed patches only as review
   material; nothing is auto-applied.

## Execution Workflow

Follow these steps **in order** every time:

### Step 1 — Scope Resolution
Determine what to scan:
- If a path was provided (`/security-review src/auth/`), scan only that scope
- If no path given, scan the **entire project** starting from the root
- Identify the language(s) and framework(s) in use (check package.json, requirements.txt,
  go.mod, Cargo.toml, pom.xml, Gemfile, composer.json, etc.)
- Read `references/language-patterns.md` to load language-specific vulnerability patterns

### Step 2 — Dependency Audit
Before scanning source code, audit dependencies first (fast wins):
- **Node.js**: Check `package.json` + `package-lock.json` for known vulnerable packages
- **Python**: Check `requirements.txt` / `pyproject.toml` / `Pipfile`
- **Java**: Check `pom.xml` / `build.gradle`
- **Ruby**: Check `Gemfile.lock`
- **Rust**: Check `Cargo.toml`
- **Go**: Check `go.sum`
- Report vulnerabilities only when confirmed by the audit tool or a cited authoritative
  advisory. Treat deprecated or suspiciously old packages as review notes unless evidence
  supports a vulnerability.
- Use `references/vulnerable-packages.md` only as a secondary heuristic after an
  authoritative audit command. Its version ranges may be stale.

### Step 3 — Secrets & Exposure Scan
Scan relevant project files (including untracked config, CI/CD, Dockerfiles, and IaC) for
the following. Exclude dependency directories, build artifacts, and other generated files
unless they are explicitly in scope:
- Hardcoded API keys, tokens, passwords, private keys
- `.env` files accidentally committed
- Secrets in comments or debug logs
- Cloud credentials (AWS, GCP, Azure, Stripe, Twilio, etc.)
- Database connection strings with credentials embedded
- Read `references/secret-patterns.md` for patterns and false-positive guidance. Never
  expose a detected value in the report.

### Step 4 — Vulnerability Deep Scan
This is the core scan. Reason about the code — don't just pattern-match.
Read `references/vuln-categories.md` for full details on each category.

**Injection Flaws**
- SQL Injection: raw queries with string interpolation, ORM misuse, second-order SQLi
- XSS: unescaped output, dangerouslySetInnerHTML, innerHTML, template injection
- Command Injection: exec/spawn/system with user input
- LDAP, XPath, Header, Log injection

**Authentication & Access Control**
- Missing authentication on sensitive endpoints
- Broken object-level authorization (BOLA/IDOR)
- JWT weaknesses (alg:none, weak secrets, no expiry validation)
- Session fixation, missing CSRF protection
- Privilege escalation paths
- Mass assignment / parameter pollution

**Data Handling**
- Sensitive data in logs, error messages, or API responses
- Missing encryption at rest or in transit
- Insecure deserialization
- Path traversal / directory traversal
- XXE (XML External Entity) processing
- SSRF (Server-Side Request Forgery)

**Cryptography**
- Use of MD5, SHA1, DES for security purposes
- Hardcoded IVs or salts
- Weak random number generation (Math.random() for tokens)
- Missing TLS certificate validation

**Business Logic**
- Race conditions (TOCTOU)
- Integer overflow in financial calculations
- Missing rate limiting on sensitive endpoints
- Predictable resource identifiers

### Step 5 — Cross-File Data Flow Analysis
After the per-file scan, perform a **holistic review**:
- Trace user-controlled input from entry points (HTTP params, headers, body, file uploads)
  all the way to sinks (DB queries, exec calls, HTML output, file writes)
- Identify vulnerabilities that only appear when looking at multiple files together
- Check for insecure trust boundaries between services or modules

### Step 6 — Self-Verification Pass
For EACH finding:
1. Re-read the relevant code with fresh eyes
2. Ask: "Is this actually exploitable, or is there sanitization I missed?"
3. Check if a framework or middleware already handles this upstream
4. Downgrade or discard findings that aren't genuine vulnerabilities
5. Assign final severity: CRITICAL / HIGH / MEDIUM / LOW / INFO

### Step 7 — Generate Security Report
Output the full report in the format defined in `references/report-format.md`.

### Step 8 — Propose Patches
For every CRITICAL and HIGH finding, generate a concrete patch:
- Show the vulnerable code (before)
- Show the fixed code (after)
- Explain what changed and why
- Preserve the original code style, variable names, and structure
- Add a comment explaining the fix inline only when it matches the existing code style;
  do not require comments in otherwise self-explanatory code.

Explicitly state: **"Review each patch before applying. Nothing has been changed yet."**

## Severity Guide

| Severity | Meaning | Example |
|----------|---------|---------|
| 🔴 CRITICAL | Immediate exploitation risk, data breach likely | SQLi, RCE, auth bypass |
| 🟠 HIGH | Serious vulnerability, exploit path exists | XSS, IDOR, hardcoded secrets |
| 🟡 MEDIUM | Exploitable with conditions or chaining | CSRF, open redirect, weak crypto |
| 🔵 LOW | Best practice violation, low direct risk | Verbose errors, missing headers |
| ⚪ INFO | Observation worth noting, not a vulnerability | Outdated dependency (no CVE) |

## Output Rules

- **Always** produce a findings summary table first (counts by severity)
- **Never** auto-apply any patch — present patches for human review only
- **Always** include a confidence rating per finding (High / Medium / Low)
- **Group findings** by category, not by file
- **Be specific** — include file path, line number, and a minimal safe snippet. Redact
  secrets, tokens, credentials, and sensitive personal data in every excerpt.
- **Explain the risk** in plain English — what could an attacker do with this?
- If no confirmed vulnerability is found, say: "No confirmed vulnerabilities found" and
  list the scope, tools run, and residual limitations. Do not equate an incomplete audit
  with a clean codebase.

## Reference Files

For detailed detection guidance, load the following reference files as needed:

- `references/vuln-categories.md` — Deep reference for every vulnerability category with detection signals, safe patterns, and escalation checkers
  - Search patterns: `SQL injection`, `XSS`, `command injection`, `SSRF`, `BOLA`, `IDOR`, `JWT`, `CSRF`, `secrets`, `cryptography`, `race condition`, `path traversal`
- `references/secret-patterns.md` — Regex patterns, entropy-based detection, and CI/CD secret risks
  - Search patterns: `API key`, `token`, `private key`, `connection string`, `entropy`, `.env`, `GitHub Actions`, `Docker`, `Terraform`
- `references/language-patterns.md` — Framework-specific vulnerability patterns for JavaScript, Python, Java, PHP, Go, Ruby, and Rust
  - Search patterns: `Express`, `React`, `Next.js`, `Django`, `Flask`, `FastAPI`, `Spring Boot`, `PHP`, `Go`, `Rails`, `Rust`
- `references/vulnerable-packages.md` — Curated CVE watchlist for npm, pip, Maven, Rubygems, Cargo, and Go modules
  - Search patterns: `lodash`, `axios`, `jsonwebtoken`, `Pillow`, `log4j`, `nokogiri`, `CVE`
- `references/report-format.md` — Structured output template for security reports with finding cards, dependency audit, secrets scan, and patch proposal formatting
  - Search patterns: `report`, `format`, `template`, `finding`, `patch`, `summary`, `confidence`
