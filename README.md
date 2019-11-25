# BigQuery Exporter

> This Salesforce app make it easy to setup scheduled exports from your org to BigQuery for use in Data Studio reports and other analytics reporting.

## Development Setup

1. Login using the CLI:

```bash
sfdx force:auth:web:login --setdefaultdevhubusername --setalias bqx
```

2. Create a scratch org:

```bash
sfdx force:org:create -a bqx -s -d 30 -f config/project-scratch-def.json
```

3. Push the source to the org:

```bash
sfdx force:source:push -f
```

4. Open the org in a browser:

```bash
sfdx force:org:open
```

You can then pull down your changes to source using:

```bash
sfdx force:source:pull -f
```

---