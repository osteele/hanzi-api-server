import request from "supertest";
import app from "../src/app";

describe("Character Decompositions API Server", () => {
  test("GET /decomposition/ returns 404 Not Found", async () => {
    const response = await request(app).get("/decomposition/");
    expect(response.status).toBe(404);
  });

  test("GET /decomposition/:character returns 200 OK with the decompositions of the character", async () => {
    const response = await request(app).get(
      `/decomposition/${encodeURI("好")}`
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

  test("GET /decomposition/:unknown_character returns 404 Not Found", async () => {
    const response = await request(app).get(
      `/decomposition/${encodeURI("👽")}`
    );
    expect(response.status).toBe(404);
  });
});
