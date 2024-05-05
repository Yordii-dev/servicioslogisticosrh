const twilio = require('twilio')

const send = async (smsData) => {
  const client = twilio(process.env.ACCOUNT_SID, process.env.AUTH_TOKEN)

  let response = await client.messages.create({
    to: smsData.to,
    from: process.env.MY_NUMBER_TWILIO,
    body: smsData.sms,
  })
  return response
}
module.exports = { send }
