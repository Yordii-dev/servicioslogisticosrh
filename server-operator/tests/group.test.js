const { sessionGroups } = require("../src/models/group")
require("../src/helpers/closeConnection")

describe("GET /groups", () => {
  test("The first group of idSession 1 is San Martin", async () => {
    const response = await sessionGroups(1)

    expect(response[0].nombre).toBe("San Martin")
  })
})
