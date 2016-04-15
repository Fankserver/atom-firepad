# http://stackoverflow.com/questions/9210542/node-js-require-cache-possible-to-invalidate
module.exports = (module) ->
  delete require.cache[require.resolve(module)]
  require(module)
