const { Kafka, logLevel } = require("kafkajs");

class KafkaConsumer {
  constructor() {
    return (async () => {
      const identifier = Math.random().toString(36).substring(7);
      const brokers = (
        process.env.KAFKA_BOOTSTRAP_SERVERS || "localhost:9092"
      ).split(",");
      const kafka = new Kafka({
        clientId: "test-client-" + identifier,
        brokers,
        logLevel: logLevel.ERROR,
      });

      this.consumer = kafka.consumer({ groupId: "test-group-" + identifier });

      await this.consumer.connect();

      await this.consumer.subscribe({ topic: "products", fromBeginning: true });

      this.disconnect = function disconnect() {
        console.log("Disconnecting consumer");
        return this.consumer.disconnect();
      };

      this.receivedMessages = [];

      await this.consumer.run({
        eachMessage: async ({ message }) => {
          console.log(`Received message: ${message.value.toString()}`);
          this.receivedMessages.push(JSON.parse(message.value.toString()));
        },
      });

      this.waitForMessage = async function (matcher, timeout = 10000) {
        const match = findMatch(this.receivedMessages, matcher);
        if (match) {
          return match;
        }

        let messages = this.receivedMessages;
        await waitFor(() => {
          const match = findMatch(messages, matcher);
          if (match) {
            return match;
          } else throw new Error("No message found yet");
        }, timeout);
      };

      return this;
    })();
  }
}

function findMatch(objectList, subObject) {
  return objectList.find((obj) => hasMatchSingle(obj, subObject));
}

function hasMatchSingle(fullObject, subObject) {
  return Object.entries(subObject).every((arr) => fullObject[arr[0]] == arr[1]);
}

async function waitFor(callback, timeout, interval = 100) {
  let timeWaited = 0;
  while (timeWaited < timeout) {
    try {
      callback();
      return;
    } catch (e) {}

    await new Promise((resolve) => setTimeout(resolve, interval));
    timeWaited += interval;
  }

  throw new Error("Timeout waiting for callback");
}

module.exports = {
  KafkaConsumer,
};
