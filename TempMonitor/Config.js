var config = {};
config.sql = {
    host: "192.168.1.101",
    port: 3306,
    database: "TempMonitor",
    user: "pi",
    password: "1q2w3e4r",
    connectionLimit: 10,
    supportBigNumbers: true,
    multipleStatements:true
};
module.exports = config;