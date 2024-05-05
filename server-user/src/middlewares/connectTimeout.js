const timeout = require("connect-timeout")

let time = 600000

//Connect-timeout
const haltOnTimedout = (req, res, next) => {
  req.setTimeout(time)
  if (!req.timedout) next()
}

module.exports = [timeout(time), haltOnTimedout]
