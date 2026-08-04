# SDLC Docker AI (a.k.a "Ask gordon") Demo

This demo is designed to help demonstrate the value of Docker AI during the development process. Specifically, it allows the demonstrator to:

1. Query Gordon for guidance on how to add a Kafka visualization service to the existing compose file.
1. Add the kafbat-ui service to compose.yaml.
1. Perform a "compose down" and "compose up" to re-launch the supporting service and include the new kafbat-ui service.

It does so by purposefully modifying the project to:

1. Remove the kafbat-ui service from the existing compose.yaml file

## Demo preparation

From the root folder of the repo, run the following - IN ORDER:

```
./demo/sdlc-e2e/setup.sh
./demo/ai-add-service/setup.sh
```
