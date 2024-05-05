const formatShemaError = (check) => {
  let errors = []
  delete check._error
  for (const field in check) {
    let rules = check[field]
    for (const rule in rules) {
      let message = rules[rule].message
      errors.push(`Error por campo ${field}: ${message}`)
    }
  }

  return errors
}

module.exports = {
  formatShemaError,
}
