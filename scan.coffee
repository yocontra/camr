Shodan = require 'shodanapi'
hackery = require 'hackery'
async = require 'async'
fs = require 'fs'

api = new Shodan 'o2J4sPGDw8yDCbaiFKRtpcCzA63gnguQ'

api.search 'port:80 after:05/01/2012 WWW-Authenticate: Basic realm="netcam"', (err, res) -> # Run a search query
  throw err if err?
  console.log "Found #{res.matches.length} results"
  hosts = (m.ip for m in res.matches)
  out = []
  trend = []
  ping = (host, done) ->
    hackery.checkHttp {host:host}, (err, body) ->
      return done() if err?
      return done unless body? and typeof body is 'string'
      return done() if body.indexOf("401") isnt -1
      out.push host
      trend.push host if body.indexOf("rdr.cgi") > -1
      done()

  async.forEachLimit hosts, 10, ping, (err) ->
    throw err if err?
    fs.writeFileSync 'cams.json', JSON.stringify out
    fs.writeFileSync 'trendnet.json', JSON.stringify trend
    console.log "#{out.length} valid systems"
    console.log "#{trend.length} trendnet systems"