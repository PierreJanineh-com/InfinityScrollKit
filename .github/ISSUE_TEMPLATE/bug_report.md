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
