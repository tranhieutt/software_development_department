#!/usr/bin/env python3
"""
Codex Safety Check — validates that AGENTS.md safety rules are present
and that critical Codex adapter files exist.

Usage:
    python scripts/codex-safety-check.py
    python scripts/codex-safety-check.py --verbose
"""
import pathlib
import sys
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
VERBOSE = "--verbose" in sys.argv

def check(description, condition, detail=""):
    status = "PASS" if condition else "FAIL"
    if VERBOSE or not condition:
        print(f"  [{status}] {description}")
        if detail and not condition:
            print(f"         {detail}")
    return condition

def main():
    failures = 0
    warnings = 0

    # 1. Required Codex files
    print("\n== Codex Adapter Files ==")
    codex_files = {
        "AGENTS.md": ROOT / "AGENTS.md",
        ".codex/START.md": ROOT / ".codex" / "START.md",
        ".codex/INSTALL.md": ROOT / ".codex" / "INSTALL.md",
        ".codex/CONTEXT.md": ROOT / ".codex" / "CONTEXT.md",
        ".codex/PRE_EDIT_CHECKLIST.md": ROOT / ".codex" / "PRE_EDIT_CHECKLIST.md",
        ".codex/COMPLETION_CHECKLIST.md": ROOT / ".codex" / "COMPLETION_CHECKLIST.md",
    }
    for name, path in codex_files.items():
        if not check(f"{name} exists", path.exists()):
            failures += 1

    # 2. Safety rules in AGENTS.md
    print("\n== Safety Rules in AGENTS.md ==")
    agents = (ROOT / "AGENTS.md").read_text(encoding="utf-8") if (ROOT / "AGENTS.md").exists() else ""

    safety_checks = {
        "Blocked Commands section": "NEVER Execute" in agents,
        "rm -rf blocked": "rm -rf" in agents,
        "git push --force blocked": "git push --force" in agents,
        "git reset --hard blocked": "git reset --hard" in agents,
        "credential exposure blocked": ".env" in agents and ".ssh" in agents,
        "curl pipe sh blocked": "curl" in agents and "| sh" in agents,
        "npm publish blocked": "npm publish" in agents,
        "sudo blocked": "sudo" in agents,
        "Risk Tiers section": "Risk Tiers" in agents,
        "Context Files section": "Context Files to Read" in agents,
    }
    for desc, cond in safety_checks.items():
        if not check(desc, cond):
            failures += 1

    # 3. Context file references exist
    print("\n== Context File References ==")
    context_refs = [
        ".claude/docs/coding-standards.md",
        ".claude/docs/coordination-rules.md",
        ".claude/docs/technical-preferences.md",
        ".claude/memory/MEMORY.md",
    ]
    for ref in context_refs:
        path = ROOT / ref
        if not check(f"{ref} exists", path.exists()):
            warnings += 1

    # 4. Safety check script referenced in preflight
    print("\n== Preflight Integration ==")
    preflight_ps = ROOT / "scripts" / "codex-preflight.ps1"
    if preflight_ps.exists():
        content = preflight_ps.read_text(encoding="utf-8")
        if not check("Safety check referenced in preflight", "codex-safety-check" in content):
            warnings += 1
            print("         Consider adding codex-safety-check to codex-preflight.ps1")
    else:
        warnings += 1
        print("  [WARN] codex-preflight.ps1 not found")

    # Summary
    print(f"\n== Summary ==")
    print(f"  Failures: {failures}")
    print(f"  Warnings: {warnings}")

    if failures > 0:
        print("\n  Codex safety check FAILED. Fix failures before proceeding.")
        sys.exit(1)
    elif warnings > 0:
        print("\n  Codex safety check passed with warnings.")
        sys.exit(0)
    else:
        print("\n  Codex safety check passed.")
        sys.exit(0)

if __name__ == "__main__":
    main()
