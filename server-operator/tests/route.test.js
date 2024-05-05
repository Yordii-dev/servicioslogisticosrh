const { getRoute } = require("../src/models/route")
require("../src/helpers/closeConnection")

describe("GET /route", () => {
  test("Vehicle Route 1 has a status 'Finalizada' ", async () => {
    const response = await getRoute(1)

    expect(response.status).toBe("Finalizada")
  })
  test("Vehicle Route 2 has a status 'En Ruta' ", async () => {
    const response = await getRoute(2)

    expect(response.status).toBe("En Ruta")
  })
  test("Vehicle Route 3 has a status 'Ruta no Iniciada'", async () => {
    const response = await getRoute(3)

    expect(response.status).toBe("Ruta no Iniciada")
  })

  test("Should respond null because vehicle does not exist", async () => {
    const response = await getRoute(9)

    expect(response).toBeNull()
  })
})
