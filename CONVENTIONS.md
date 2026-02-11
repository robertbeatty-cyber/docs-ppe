# Documentation Conventions & Guidelines

**Last updated:** 2026-02-11

This document defines the standards and conventions for all documentation in the PPE Medical documentation repository.

---

## File & Folder Naming Conventions

### General Rules
- **Use lowercase letters** with hyphens to separate words
- **Preserve uppercase for acronyms**: SOP, RFC, etc.
- **Use descriptive, specific names** that clearly indicate content
- **Keep names concise** but not cryptic (30-50 characters max)

### Examples

**Correct:**
```
staged-website-updates-SOP.md
regression-test-ppemedical-com.md
visual-regression-testing-guide.md
```

**Incorrect:**
```
Staged-Website-Updates-SOP.md  (Title Case)
staged_website_updates_sop.md  (underscores)
StagedWebsiteUpdatesSOP.md     (PascalCase)
stgd-upd-sop.md                (too cryptic)
```

### Convention File Exceptions

These files use special naming by convention:
- `README.md` (uppercase - GitHub convention)
- `CLAUDE.md` (uppercase - Claude Code convention)
- `CONVENTIONS.md` (this file - uppercase for visibility)

### Folder Naming

All folders use **lowercase with hyphens**:
```
sops/
sops/maintenance/
checklists/
guides/
```

---

## Directory Structure

```
docs-ppe/
├── CLAUDE.md              (AI assistant context)
├── CONVENTIONS.md         (this file)
├── README.md              (repository entry point)
├── sops/
│   ├── README.md
│   └── maintenance/       (website maintenance SOPs)
├── checklists/            (per-site regression test checklists)
│   └── README.md
└── guides/                (instructional reference guides)
    └── README.md
```

### `/sops/maintenance/` - Standard Operating Procedures
**Purpose:** Step-by-step procedural documentation for website maintenance

**Use for:**
- Staged update workflows
- Maintenance procedures
- Repeatable operational tasks

### `/checklists/` - Regression Test Checklists
**Purpose:** Actionable per-site test checklists executed during update cycles

**Use for:**
- Site-specific regression test items
- Plugin-specific functional tests
- Post-update verification

### `/guides/` - Instructional References
**Purpose:** How-to guides and tool documentation

**Use for:**
- Tool setup and usage instructions
- Testing methodology references
- Technical how-to documents

---

## SOP Metadata Header Format

All SOPs must include this metadata header:

```markdown
# SOP: [Clear, Descriptive Title]

**Version:** X.Y
**Date:** YYYY-MM-DD
**Status:** [Active/Draft]
**Last updated:** YYYY-MM-DD
**Last reviewed by:** [Name/Role]
**Applies to:** [Roles who use this SOP]
**Purpose:** [One sentence: what this SOP accomplishes]

---
```

### Core SOP Sections (in order)

1. **Prerequisites** - Requirements before starting (use ✅ checkmarks)
2. **What is This SOP?** - 2-3 sentence intro
3. **Roles & Responsibilities** - Who does what
4. **Process Workflow** - Numbered steps with verification and **Outcome:** statements
5. **Common Mistakes & How to Avoid Them** - Anti-patterns
6. **Verification Checklist** - Final validation items
7. **Related Documents** - Cross-references
8. **Footer** - Review dates

---

## Checklist Document Format

Regression test checklists use this structure:

```markdown
# Regression Test Checklist: [site-name.com]

**Last updated:** YYYY-MM-DD
**Site:** [Production URL]
**Staging:** [Staging URL]
**Risk level:** [Standard/High/Critical]

---
```

Sections group tests by plugin or functional area. Each test item uses checkbox format:
```markdown
- [ ] Test description
```

Include a plugin version table at the end for tracking.

---

## Guide Document Format

Guides use a simplified header:

```markdown
# [Guide Title]

**Last updated:** YYYY-MM-DD
**Purpose:** [What this guide covers]

---
```

---

## Markdown Standards

### Heading Hierarchy
```markdown
# Document Title (H1 - only one per document)
## Major Section (H2)
### Subsection (H3)
#### Detail (H4)
```

### Cross-References
Use relative links between documents:
```markdown
See: [Staged Website Updates SOP](sops/maintenance/staged-website-updates-SOP.md)
```

### Tables
Use tables for structured data:
```markdown
| Column 1 | Column 2 | Column 3 |
|-----------|----------|----------|
| Data      | Data     | Data     |
```

### Code Blocks
Use fenced code blocks with language identifiers:
````markdown
```bash
backstop test
```
````

### Checklists
```markdown
- [ ] Unchecked item
- [x] Checked item
```

---

## Commit Message Format

```
[Type]: Brief description

Longer description if needed
- Bullet points for multiple changes
```

**Types:** `Docs:`, `SOP:`, `Checklist:`, `Guide:`, `Fix:`, `Refactor:`

### Rules
- No em dashes (use regular dashes or "--" instead)
- Keep the first line under 72 characters
- Use imperative mood ("Add regression checklist" not "Added regression checklist")

---

## Quality Checklist

Before finalizing any document:

- [ ] Title is clear and follows naming convention
- [ ] File is in correct directory
- [ ] Last updated date is current
- [ ] Markdown formatting is correct (headers, lists, code blocks)
- [ ] All relative links work
- [ ] No em dashes used anywhere
- [ ] Language is professional and clear
- [ ] Technical accuracy verified
- [ ] No sensitive information included (credentials, private keys, etc.)

---

## Creating New Documents

1. **Check if similar content exists** (avoid duplication)
2. **Determine correct directory** using the structure above
3. **Follow naming conventions** (lowercase-with-hyphens, uppercase acronyms)
4. **Add to the directory's README.md** table of contents
5. **Cross-link** from related documents
6. **Add "Last updated" date**

---

**Document Owner:** Technical Lead

---

*This is a living document. Update when conventions change.*
