const { getItems } = require("../src/models/item")
require("../src/helpers/closeConnection")

describe("GET /item", () => {
  test("First delivery of vehicle 1 has 8 items", async () => {
    const response = await getItems(1, 71158234)

    expect(response.length).toBe(8)
  })

  test("1003117 item of second delivery of vehicle 1 has 1 given", async () => {
    const response = await getItems(1, 71158100)

    expect(response.find((el) => el.id == 1003117).given).toBe(1)
  })
})
