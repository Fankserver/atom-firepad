{View} = require 'space-pen'

module.exports =
class ShareView extends View
  @content: ->
    @div class: 'firepad overlay from-bottom', =>
      @div class: 'message', outlet: 'message'

  show: (identifier) ->
    atom.views.getView(atom.workspace).appendChild(@element)

    @message.text('This file is being shared (' + identifier + ')')
