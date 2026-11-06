# Operations alerts

Operations monitor checks backup and reminder runs when they finish and once an hour. It opens one issue assigned to TaylorOD when a run fails, is cancelled, times out, or becomes overdue. The issue closes after a healthy check. Disabled schedules are ignored.

Backups are overdue after 28 hours without a successful run. Reminders are overdue after one hour. These allowances tolerate ordinary GitHub scheduling delays. Alerts link to Actions logs without copying customer data or secrets.

Run Operations monitor manually with test_alert enabled to check issue creation. Close the Monitoring test issue afterward. GitHub delivers assignment notifications according to your notification settings. Confirm the test notification in your GitHub inbox and enable email notifications if you want email delivery.

The monitor needs no database or messaging credentials. It checks out main and never executes code or downloads artifacts from the workflow that triggered it.

GitHub can delay or disable scheduled workflows. This monitor cannot report its own outage or a GitHub wide outage. Check Actions periodically and use an independent monitoring service if you need guaranteed missing run alerts. No monitor pings the sleeping Render app.
