const { getTrackin } = require('../models/tracking')
const { getDates, getActualDate, getOnly } = require('../helpers/history')

const getHistory = async (userId) => {
  const history = []

  let dates = await getDates(userId)
  let mothActual = getOnly('month', getActualDate())

  for (const date of dates) {
    let moth = getOnly('month', date)
    if (mothActual != moth) continue

    let tracking = await getTrackin(userId, date)

    history.push({ date, tracking })
  }

  return history
}

module.exports = { getHistory }
