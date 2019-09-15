# Let The People Know!

This simple action prints commit messages to the target branch into a
[Slack](https://slack.com/) channel. It is intended for release announcements.

You _must_ supply a `SLACK_WEBHOOK` in your repository's secrets.

## Example usage

```
name: Release workflow

on:
  push:
    branches:
    - release
jobs:
  let-the-people-know:
    runs-on: ubuntu-latest
    name: Let the people know
    steps:
    - name: Let the people know
      uses: TheTeaNerd/let-the-people-know@master
      env:
        SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
```
