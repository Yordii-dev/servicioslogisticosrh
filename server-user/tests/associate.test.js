const { sessionAssociates } = require("../src/models/associate")
require("../src/helpers/closeConnection")

describe("GET /associates", () => {
  test("The first associate of idSession 1 is of group San Martin", async () => {
    const response = await sessionAssociates(1)

    expect(response[0].grupo).toBe("San Martin")
  })
})
