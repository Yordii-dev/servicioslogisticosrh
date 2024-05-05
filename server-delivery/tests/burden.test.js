const { burdens } = require("../src/models/burden")
require("../src/helpers/closeConnection")

describe("GET /burdens", () => {
  test("Session 1 should have 2 burdens", async () => {
    const response = await burdens(1, "all")
    expect(response.length).toBe(2)
  })
})
