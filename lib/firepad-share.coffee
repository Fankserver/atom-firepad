{CompositeDisposable} = require 'atom'
{Emitter} = require 'event-kit'

class FirepadShare

  constructor: (@editor, @shareIdentifier) ->
    console.log 'create', @shareIdentifier

    @emitter = new Emitter
    @subscriptions = new CompositeDisposable

    @handleEditorEvents()

    # hash = Crypto.createHash('sha256').update(@shareIdentifier).digest('base64')
    # @firebase = new Firebase(atom.config.get('firepad.firebaseUrl')).child(hash)

  handleEditorEvents: ->
    @subscriptions.add @editor.onDidDestroy =>
      @remove()

    @subscriptions.add @editor.onDidChangeCursorPosition =>
      console.log 'cursor change'

    @subscriptions.add @editor.onDidStopChanging =>
      console.log 'stop change'

    @subscriptions.add @editor.getBuffer().onDidChange =>
      console.log 'change'

  getEditor: ->
    @editor

  getShareIdentifier: ->
    @shareIdentifier

  remove: ->
    console.log 'remove'

    @subscriptions.dispose()
    @emitter.emit 'did-destroy'

  onDidDestroy: (callback) ->
    @emitter.on 'did-destroy', callback

module.exports = FirepadShare
