const {
  createManagedDelivery,
  createManagedOrders,
} = require('../helpers/detail')

const updateDetail = async (deliveryId, { section, data }) => {
  if (section == 'managed') {
    let response = await createManagedDelivery(deliveryId, data)
    return response
  }
  if (section == 'itemsManaged') {
    let response = await createManagedOrders(deliveryId, data)
    return response
  }
}

module.exports = { updateDetail }
