const { details } = require("../src/models/deliveryDetails")
require("../src/helpers/closeConnection")

describe("GET /delivery", () => {
  test("Client of first delivery of vehicle 1 is 'PUMA DE PARI LUCIA'", async () => {
    const response = await details(1, 71158234)

    expect(response.client.name).toBe("PUMA DE PARI LUCIA")
  })
  test("First delivery of vehicle 1 does not have managed items", async () => {
    const response = await details(1, 71158234)

    expect(response.itemsManaged).toBe(false)
  })
  test("Second delivery of vehicle 1 have managed items", async () => {
    const response = await details(1, 71158100)

    expect(response.itemsManaged).toBe(true)
  })
})
