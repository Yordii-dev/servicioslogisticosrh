const { sessionVehicles } = require("../src/models/vehicle")
require("../src/helpers/closeConnection")

describe("GET /vehicles", () => {
  test("Session 1 should have 7 vehicles in date 'latest'", async () => {
    const response = await sessionVehicles(1, "latest")

    expect(response.length).toBe(7)
  })
  test("Session 2 should have 1 vehicles in date 'latest'", async () => {
    const response = await sessionVehicles(2, "latest")

    expect(response.length).toBe(1)
  })
})
