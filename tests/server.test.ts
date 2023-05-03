import request from "supertest";
import app from "../src/app";

describe("Character Decompositions API Server", () => {
  test("GET /character/composition/ returns 404 Not Found", async () => {
    const response = await request(app).get("/decomposition/");
    expect(response.status).toBe(404);
  });

  test("GET /character/:character/composition returns 200 OK with the decompositions of the character", async () => {
    const response = await request(app).get(
      `/character/${encodeURI("好")}/composition`
    );
    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      component: "好",
      strokes: 6,
      decompositionType: "吅",
      leftComponent: "女",
      leftStrokes: 3,
      rightComponent: "子",
      rightStrokes: 3,
      notes: "/",
      radical: "女",
      signature: "VND",
    });
  });

  test("GET /character/:unknown_character/composition returns 404 Not Found", async () => {
    const response = await request(app).get(
      `/character/${encodeURI("👽")}/composition`
    );
    expect(response.status).toBe(404);
  });
});

describe("Health and Status endpoints", () => {
  it("should respond with 200 and 'OK' for GET /health", async () => {
    const response = await request(app).get("/health");

    expect(response.status).toEqual(200);
    expect(response.text).toEqual("OK");
  });

  it("should respond with status object for GET /status", async () => {
    const response = await request(app).get("/status");

    expect(response.status).toEqual(200);
    expect(response.body.status).toEqual("OK");
    expect(response.body.version).toBeDefined();
    expect(response.body.uptime).toBeGreaterThan(0);
  });
});
