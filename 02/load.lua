-- load.lua
function request()
  return wrk.format('GET', '/')
end