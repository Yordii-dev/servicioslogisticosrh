let poolTwo = require("../databases/two");

const getUsersFromTwo = async () => {
  if (process.env.NODE_ENV == "development") {
    return [
      { correo: "dev_cr031411@gmail.com" },
      { correo: "dev_Elizabeth@gmail.com" },
    ];
  } else {
    let rolId = 1;
    const results = await poolTwo.query(`select correo from tbl_user 
    where id_rol = ${rolId}`);

    return results;
  }
};

module.exports = { getUsersFromTwo };

