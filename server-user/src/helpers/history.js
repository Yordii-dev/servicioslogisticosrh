const User = require('../classes/User.js')

async function getDates(userId) {
  let loads = await User.getLoads(userId)
  let dates = loads.map((el) => el.date)
  return dates
}

function getActualDate() {
  let now = new Date()
  return now.toISOString().split('T')[0]
}

function getOnly(part, date) {
  if (part == 'day') {
    return date.split('-')[2]
  }
  if (part == 'month') {
    return date.split('-')[1]
  }
  if (part == 'year') {
    return date.split('-')[0]
  }
  return null
}

module.exports = { getDates, getActualDate, getOnly }
