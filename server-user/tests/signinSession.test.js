const app = require("../src/app")
const request = require("supertest")
require("../src/helpers/closeConnection")

describe("POST /signinSession", () => {
  test("should respond with a string token", async () => {
    const response = await request(app)
      .post("/server/signinSession")
      .send({ email: "cr031411@gmail.com" })
      .set("Accept", "application/json")

    expect(typeof response.body).toBe("string")
  })
  test("should respond with a null", async () => {
    const response = await request(app)
      .post("/server/signinSession")
      .send({ email: "failEmail" })
      .set("Accept", "application/json")

    expect(response.body).toBeNull()
  })
})
