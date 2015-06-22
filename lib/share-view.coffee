{View} = require 'space-pen'

module.exports =
class ShareView extends View
  @content: ->
    @div class: 'firepad overlay from-bottom', =>
      @div 'This file is being shared', class: 'message'

  show: ->
    atom.views.getView(atom.workspace).appendChild(@element);
