const { tracking } = require("../src/models/tracking")
require("../src/helpers/closeConnection")

describe("GET /tracking", () => {
  test("Tracking length of Session 1 with date 'latest' respond 7", async () => {
    const response = await tracking(1, "latest")
    expect(response.length).toBe(7)
  })

  test("Tracking length of Session 2 with date 'latest' respond 1", async () => {
    const response = await tracking(2, "latest")
    expect(response.length).toBe(1)
  })
})
