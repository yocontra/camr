Shodan = require 'shodanapi'
hackery = require 'hackery'
async = require 'async'
fs = require 'fs'

api = new Shodan 'o2J4sPGDw8yDCbaiFKRtpcCzA63gnguQ'

total = 0
api.search 'port:80 WWW-Authenticate: Basic realm="netcam"', 8000, (err, res) -> # Run a search query
  throw err if err?
  console.log "Found #{res.matches.length} results"
  hosts = (m.ip for m in res.matches)
  out = JSON.parse fs.readFileSync 'cams.json'
  trend = JSON.parse fs.readFileSync 'trendnet.json'
  ping = (host, done) ->
    hackery.checkHttp {host:host}, (err, body) ->
      ++total
      console.log "#{total}/#{res.matches.length} | #{out.length}/#{res.matches.length}"
      return done() if err?
      return done() unless body? and typeof body is 'string'
      return done() if body.indexOf("401") isnt -1
      out.push host
      fs.writeFileSync 'cams.json', JSON.stringify out
      if body.indexOf("rdr.cgi") > -1
        trend.push host
        console.log "trendnet: #{host}"
        fs.writeFileSync 'trendnet.json', JSON.stringify trend
      done()

  async.forEachLimit hosts, 50, ping, (err) ->
    throw err if err?
    console.log "#{out.length} valid systems"
    console.log "#{trend.length} trendnet systems"