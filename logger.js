const { createLogger, format, transport } = require("winston");
const logger = createLogger({
  level: "info",
  format: format.combine(format.timestamp(), format.json()),
  transport: [
    new transport.Console(),
    new transport.File({ filename: "logs/error.log", level: "error" }),
    new transport.File({ filename: "logs/combined.log" }),
  ],
});

module.exports = logger;
