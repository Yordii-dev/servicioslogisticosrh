const app = require("../src/app")
const request = require("supertest")
require("../src/helpers/closeConnection")

describe("GET /signinUser", () => {
  test("idVehicle 1 with pin '1234' should respond a string token", async () => {
    const response = await request(app)
      .post("/server/signinUser")
      .send({ idVehicle: 1, pin: "1234" })
      .set("Accept", "application/json")

    expect(typeof response.body).toBe("string")
  })
  test("idVehicle 1 with pin 'failPassword' should respond null", async () => {
    const response = await request(app)
      .post("/server/signinUser")
      .send({ idVehicle: 1, pin: "failPassword" })
      .set("Accept", "application/json")

    expect(response.body).toBeNull()
  })
})
