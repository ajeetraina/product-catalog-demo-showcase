const { Kafka, Partitioners } = require("kafkajs");

let producer;

async function getProducer() {
  if (producer) {
    return producer;
  }

  const BROKER_URLS = (
    process.env.KAFKA_BOOTSTRAP_SERVERS || "localhost:9092"
  ).split(",");

  const kafka = new Kafka({
    clientId: "catalog-service",
    brokers: BROKER_URLS,
  });

  const p = kafka.producer({
    createPartitioner: Partitioners.LegacyPartitioner,
  });
  await p.connect();

  producer = p;
  return producer;
}

async function teardown() {
  if (producer) {
    await producer.disconnect();
  }
}

async function publishEvent(topic, event) {
  const producer = await getProducer();

  try {
    await producer.send({
      topic,
      messages: [{ value: JSON.stringify(event) }],
    });
  } catch (e) {
    console.error("Failed to publish event", e);
  }
}

module.exports = {
  publishEvent,
  teardown,
};
