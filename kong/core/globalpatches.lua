local meta = require "kong.meta"
local randomseed = math.randomseed

_G._KONG = {
  _NAME = meta._NAME,
  _VERSION = meta._VERSION
}

local seed

--- Seeds the random generator, use with care.
-- The uuid.seed() method will create a unique seed per worker
-- process, using a combination of both time and the worker's pid.
-- We then disable (or rather, no-op) `math.randomseed()` to prevent
-- third-party modules from overriding our correct seed (many modules
-- make a wrong usage of `math.randomseed()` by calling it multiple times
-- or do not use unique seed for Nginx workers.
-- luacheck: globals math
_G.math.randomseed = function()
  if ngx.get_phase() ~= "init_worker" then
    ngx.log(ngx.ERR, "math.randomseed() must be called in init_worker")
  elseif not seed then
    seed = ngx.time() * ngx.worker.pid()
    ngx.log(ngx.DEBUG, "seeding random number generator for worker ",
                        ngx.worker.id(), " with: ", seed)
    randomseed(seed)
  else
    ngx.log(ngx.DEBUG, "attempt to seed random number generator, but ",
                       "already seeded")
  end

  return seed
end

