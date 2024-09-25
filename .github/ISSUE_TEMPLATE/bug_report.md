---
name: Bug report
about: Create a report to help us improve
title: ''
labels: 'bug'
assignees: ''
body:
- type: dropdown
  id: implementation
  attributes:
    label: How did you implement the package?
    options:
      - CocoaPods
      - Swift Package Manager (SPM)
  validations:
    required: true
  
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment (please complete the following information):**
 - Xcode version: [e.g. 16.0]
 - OS: [e.g. watchOS, iOS]

**Additional context**
Add any other context about the problem here.
