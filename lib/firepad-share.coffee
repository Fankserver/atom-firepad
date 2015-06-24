{CompositeDisposable} = require 'atom'
{Emitter} = require 'event-kit'
Crypto = require 'crypto'
Firebase = require 'firebase'
Firepad = require './firepad-lib'

class FirepadShare

  constructor: (@editor, @shareIdentifier) ->
    @emitter = new Emitter
    @subscriptions = new CompositeDisposable

    @handleEditorEvents()

    hash = Crypto.createHash('sha256').update(@shareIdentifier).digest('base64')
    @firebase = new Firebase(atom.config.get('firepad.firebaseUrl')).child(hash)

    @firebase.once 'value', (snapshot) =>
      options = {sv_: Firebase.ServerValue.TIMESTAMP}
      if not snapshot.val() and @editor.getText() isnt ''
        options.overwrite = true
      else
        @editor.setText ''
      @firepad = Firepad.fromAtom @firebase, @editor, options
    #   @shareview.show(@shareIdentifier)

  handleEditorEvents: ->
    @subscriptions.add @editor.onDidDestroy =>
      @remove()

    # @subscriptions.add @editor.onDidChangeCursorPosition =>
    #   console.log 'cursor change'
    #
    # @subscriptions.add @editor.onDidStopChanging =>
    #   console.log 'stop change'
    #
    # @subscriptions.add @editor.getBuffer().onDidChange =>
    #   console.log 'change'

  getEditor: ->
    @editor

  getShareIdentifier: ->
    @shareIdentifier

  remove: ->
    # @firepad.dispose() # Won't work #4
    # @subscriptions.dispose()
    # @emitter.emit 'did-destroy'
    atom.notifications.addWarning('The "unshare" function is due dependencies buggy, and wont work. Please close the pane, to stop sharing!')

  onDidDestroy: (callback) ->
    @emitter.on 'did-destroy', callback

module.exports = FirepadShare
