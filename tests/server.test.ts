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
      decompositionType: "吅",
      leftComponent: "女",
      leftStrokes: 3,
      notes: "/",
      rightComponent: "子",
      rightStrokes: 3,
      section: "女",
      signature: "VND",
      strokes: 6,
    });
  });

  test("GET /character/:unknown_character/composition returns 404 Not Found", async () => {
    const response = await request(app).get(
      `/character/${encodeURI("👽")}/composition`
    );
    expect(response.status).toBe(404);
  });
});
