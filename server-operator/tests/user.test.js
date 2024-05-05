const { sessionUsers } = require("../src/models/user")
require("../src/helpers/closeConnection")

describe("GET /users", () => {
  test("The first user of idSession 1 is Yordii CE", async () => {
    const response = await sessionUsers(1)

    expect(response[0].nombreCompleto).toBe("Yordii CE")
  })
})
