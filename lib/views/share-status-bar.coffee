{View} = require 'atom-space-pen-views'

module.exports =
class ShareStatusBarView extends View
  @content: ->
    @div class: 'inline-block text-warning', tabindex: -1, =>
      @span outlet: 'shareInfo'

  initialize: ->

  destroy: ->
    @detach()

  show: (shareIdentifier) ->
    @shareInfo.text "Shared (#{shareIdentifier})"

  hide: ->
    @shareInfo.text ""
