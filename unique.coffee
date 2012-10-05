fs = require 'fs'

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

fs.writeFileSync "cams.json", JSON.stringify JSON.parse(fs.readFileSync("cams.json")).unique(), null, 4
fs.writeFileSync "trendnet.json", JSON.stringify JSON.parse(fs.readFileSync("trendnet.json")).unique(), null, 4

console.log JSON.parse(fs.readFileSync("cams.json")).length
console.log JSON.parse(fs.readFileSync("trendnet.json")).length