const { vehicleUserDeliveries } = require("../src/models/delivery")
require("../src/helpers/closeConnection")

describe("GET /delivery", () => {
  test("Vehicle 1 has 19 deliveries", async () => {
    const response = await vehicleUserDeliveries(1)

    expect(response.length).toBe(19)
  })

  test("First delivery of Vehicle 1 is 'Entregado'", async () => {
    const response = await vehicleUserDeliveries(1)

    expect(response[0].managed).toBe("Entregado")
  })
})
