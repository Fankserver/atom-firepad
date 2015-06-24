{CompositeDisposable} = require 'atom'
{TextEditorView} = require 'atom-space-pen-views'
{View} = require 'space-pen'
{Emitter} = require 'event-kit'

module.exports =
class ShareSetupView extends View
  @content: ->
    @div class: 'firepad overlay from-top mini', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'message', outlet: 'message'

  detaching: false

  constructor: ->
    super
    @emitter = new Emitter

  initialize: ->
    @miniEditor.on 'focusout', => @detach() unless @detaching

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:confirm': =>
      @emitter.emit 'confirm', @miniEditor.getText()
      @detach()

    @subscriptions.add atom.commands.add 'atom-workspace', 'core:cancel': => @detach()

  detach: ->
    return unless @hasParent()
    @detaching = true
    @miniEditor.setText('')
    super
    @detaching = false

  show: ->
    if atom.workspace.getActiveTextEditor()
      atom.views.getView(atom.workspace).appendChild(@element)

      @message.text('Enter a string to identify this share session')

      randomString = Math.random().toString(36).slice(2, 10)
      @miniEditor.setText(randomString)
      @miniEditor.focus()

  onDidConfirm: (callback) ->
    @emitter.on 'confirm', callback
