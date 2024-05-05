const multer = require('multer')

//Multer
const storage = multer.diskStorage({
  destination: 'src/images/',
  filename: function (req, file, cb) {
    let milliseconds = new Date().getTime()

    req.dataImage = {
      name: `${milliseconds}_${file.originalname}`,
    }

    cb('', req.dataImage.name)
  },
})
const upload = multer({
  storage,
})

module.exports = upload.single('image')
