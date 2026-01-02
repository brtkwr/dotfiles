---
name: slack-review
description: Post a message to a Slack channel asking for PR review.
---

# Slack Review Request

Post a message to a Slack channel asking for PR review.

## Team Mappings

When the user asks for "platform team" or "platform review":
- Channel: `tech-platform` (ID: C02PQ9JT6G0)
- Team mention: `<!subteam^S04FYKQGH5F>` (@platform-team)

## Instructions

When this skill is invoked:

1. Get the current PR URL using `gh pr view --json url -q .url`
2. Get the PR title using `gh pr view --json title -q .title`
3. Determine which team/channel based on user request:
   - If "platform team" or "platform review" → use tech-platform channel and platform-team mention
   - Otherwise, ask the user which channel/team to notify
4. Post a message to Slack using the API:

```bash
curl -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "<CHANNEL_NAME>",
    "text": "<TEAM_MENTION> <PR_URL> please review - <SHORT_DESCRIPTION>"
  }'
```

## Details

- Use `$SLACK_USER_TOKEN` environment variable for authentication
- Keep the description concise (one line summary of what the PR does)
- Team mentions use format: `<!subteam^TEAM_ID>`

## Examples

### Platform team review
```
@platform-team https://github.com/two-inc/infra/pull/1658 please review - fixes GitHub Actions workload identity failures when branch names are too long
```

### Other team review
Ask user for channel and team mention details if not platform team.
