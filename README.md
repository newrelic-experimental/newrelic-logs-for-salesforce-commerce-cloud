[![New Relic Experimental header](https://github.com/newrelic/opensource-website/raw/master/src/images/categories/Experimental.png)](https://opensource.newrelic.com/oss-category/#new-relic-experimental)

# New Relic Logs for Salesforce Commerce Cloud

A Docker image purpose-built to monitor Salesforce Commerce Cloud (fka Demandware) logs using New Relic Logs.

This image contains 2 processes to collect, process and send these logs to New Relic:
  * [cctail](https://github.com/newrelic-forks/cctail) - a node.js app used to tail and consolidate logs from any SFCC host via WebDAV.
  * [FluentD](https://www.fluentd.org) - an open source data collector for unified logging layer.
    * [fluent-plugin-newrelic](https://docs.newrelic.com/docs/logs/enable-log-management-new-relic/enable-log-monitoring-new-relic/fluentd-plugin-log-forwarding) - New Relic's official FluentD plugin to send log events to the New Relic Logs endpoint.
    * [fluent-grok-parser](https://github.com/fluent/fluent-plugin-grok-parser) - Fluentd's official plugin that enables Logstash's Grok-like parsing logic.

## Installation

1. Use `git` to clone this repository into a suitable folder:
```sh
git clone https://github.com/newrelic-experimental/newrelic-logs-for-salesforce-commerce-cloud.git nr-logs-for-sfcc
```
2. Use `docker` to build a container from this image:
```sh
docker build -t 'nr-logs-for-sfcc:latest' ./nr-logs-for-sfcc
```

## Usage

1. Obtain an Insights API Insert key from your account, [as described here](https://docs.newrelic.com/docs/telemetry-data-platform/ingest-manage-data/ingest-apis/use-event-api-report-custom-events#register).
2. Use the following docker command to run your container.
```sh
docker run -d -e "NEWRELIC_API_KEY=<your_Insert_API_key>" -e "SFCC_HOSTNAME=<your_sfcc_host>" -e "SFCC_CLIENT_ID=<your_sfcc_client_id>" -e "SFCC_CLIENT_SECRET=<your_sfcc_client_secret>" nr-logs-for-sfcc:latest
```
* If you prefer to store these environment variables in a file like [this example](./sfcc.env), you can run docker like so:
```sh
docker run -d --env-file=sfcc.env nr-logs-for-sfcc:latest
```
3. Login to New Relic and open the [Logs UI](https://one.newrelic.com/launcher/logger.log-launcher), look for entries with `sfcc.xxxx` as their service_name.

## Troubleshooting

If you are not seeing any logs in New Relic Logs:
1. _Wait a few minutes!_ As there are a couple steps between your logs and New Relic, it can take a few minutes for them to start rolling in, especially if you have many different log types or high log volumes.
2. Connect to your docker container at command-line and review the logs. All of the pertinent logs (`cctail.log`, `fluentd.log` and `supervisord.log`) are found in the root directory. The following example also shows how to get the container ID easily and re-use that for connecting:
```sh
thiscontainer=$(docker ps | grep nr-logs-for-sfcc:latest | head -n1 | awk '{print $1;}')
docker exec -t -i $thiscontainer /bin/sh
```

  * What each log will tell you:
    * `fluentd.log` - issues with the New Relic Insert API Key or log parsing rules. Messages like `[error]: #0 Response was 403 {}` indicate an invalid or unset key.
    * `cctail.log` - issues with your SFCC credentials.
    * `supervisord.log` - container-wide issues, i.e. those caused by changes made to `Dockerfile`, `entrypoint.sh` or `supervisord.conf`.
3. You can run cctail in Debug Mode, using the `CCTAIL_ARGS` environment variable at `docker run` time. This will send more information into `cctail.log` about what logs are being polled, and how many log records are being reported from each.
```sh
docker run -d -e "CCTAIL_ARGS=-d" -e "NEWRELIC_API_KEY=<your_Insert_API_key>" -e "SFCC_HOSTNAME=<your_sfcc_host>" -e "SFCC_CLIENT_ID=<your_sfcc_client_id>" -e "SFCC_CLIENT_SECRET=<your_sfcc_client_secret>" nr-logs-for-sfcc:latest
```
or (if using an env file):
```sh
docker run -d -e "CCTAIL_ARGS=-d" -env-file=sfcc.env nr-logs-for-sfcc:latest
```
## Support

New Relic has open-sourced this project. This project is provided AS-IS WITHOUT WARRANTY OR DEDICATED SUPPORT. Issues and contributions should be reported to the project here on GitHub. We encourage you to bring your experiences and questions to the [Explorers Hub](https://discuss.newrelic.com) where our community members collaborate on solutions and new ideas.

## Contributing

We encourage your contributions to improve New Relic Logs for Salesforce Commerce Cloud! Keep in mind when you submit your pull request, you'll need to sign the CLA via the click-through using CLA-Assistant. You only have to sign the CLA one time per project.

If you have any questions, or to execute our corporate CLA, required if your contribution is on behalf of a company,  please drop us an email at opensource@newrelic.com.

**A note about vulnerabilities**

As noted in our [security policy](../../security/policy), New Relic is committed to the privacy and security of our customers and their data. We believe that providing coordinated disclosure by security researchers and engaging with the security community are important means to achieve our security goals.

If you believe you have found a security vulnerability in this project or any of New Relic's products or websites, we welcome and greatly appreciate you reporting it to New Relic through [HackerOne](https://hackerone.com/newrelic).

## License

New Relic Logs for Salesforce Commerce Cloud is licensed under the [Apache 2.0](http://apache.org/licenses/LICENSE-2.0.txt) License.
