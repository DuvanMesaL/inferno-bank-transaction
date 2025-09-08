import { DynamoDBClient, PutItemCommand, QueryCommand } from "@aws-sdk/client-dynamodb";
import { v4 as uuid } from "uuid";

const dynamo = new DynamoDBClient({});

export const processCardRequest = async (event) => {
  for (const rec of event.Records ?? []) {
    const msg = JSON.parse(rec.body);
    const { userId, request } = msg;

    const txId = uuid();
    const item = {
      userId:   { S: userId },
      txId:     { S: txId },
      type:     { S: request },
      status:   { S: "CREATED" },
      createdAt:{ S: new Date().toISOString() }
    };

    await dynamo.send(new PutItemCommand({
      TableName: process.env.TX_TABLE,
      Item: item
    }));
  }
  return {};
};

export const listTransactions = async (event) => {
  const userId = event.pathParameters?.user_id;
  const out = await dynamo.send(new QueryCommand({
    TableName: process.env.TX_TABLE,
    KeyConditionExpression: "userId = :u",
    ExpressionAttributeValues: { ":u": { S: userId } }
  }));

  const items = (out.Items ?? []).map(it => ({
    txId: it.txId.S,
    type: it.type.S,
    status: it.status.S,
    createdAt: it.createdAt.S
  }));

  return { statusCode: 200, body: JSON.stringify({ ok: true, items }) };
};
