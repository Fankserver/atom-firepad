{CompositeDisposable} = require 'atom'
{Emitter} = require 'event-kit'
Crypto = require 'crypto'
os = require 'os'
requireUncached = require './utils/requireUncached'

module.exports =
class FirepadShare

  constructor: (@editor, @shareIdentifier) ->
    @emitter = new Emitter
    @subscriptions = new CompositeDisposable

    @handleEditorEvents()

    hash = Crypto.createHash('sha256').update(@shareIdentifier).digest('base64')
    @userId = Math.random().toString(36).slice(2, 10)

    Firebase = requireUncached 'firebase'
    @firebase = new Firebase(atom.config.get('firepad.firebaseUrl')).child(hash)
    @firebaseUsers = @firebase.child('users')
    @firebaseContent = @firebase.child('content')

    @firebaseUsers.on 'value', (snapshot) =>
      @attachDecoration(snapshot)

    @firebaseUserSelf = @firebaseUsers.push
      userId: @userId
      displayName: os.hostname()
      pos: @editor.getCursorBufferPosition()
      color: '#' + Math.floor(Math.random() * 256 * 256 * 256).toString(16)

    @firebaseCursor = @firebaseUserSelf.child('pos')

    @firebaseContent.on 'value', (snapshot) =>
      content = snapshot.val() or @editor.getText()
      if not content
        @editor.setText ''
      else
        pos = @editor.getCursorBufferPosition()
        @editor.setText content
        @editor.setCursorScreenPosition pos
    #   @shareview.show(@shareIdentifier)

  handleEditorEvents: ->
    @subscriptions.add @editor.onDidStopChanging =>
      @updateContent()

    @subscriptions.add @editor.onDidChangeCursorPosition (event) =>
      @updateCursorPosition(event)

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

  updateContent: ->
    @firebaseContent.set(@editor.getText())

  attachDecoration: (userSnapshot) ->
    # reset markers
    @destroyMarkers()

    # attach decorations
    users = userSnapshot.val()
    for uid, user of users
      # uncomment below if you want to hide the cursor of self
      # continue if user.userId is @userId
      marker = @editor.markBufferRange([
        [user.pos.row, 0]
        [user.pos.row, 0]
      ], invalidate: 'never')
      @markers.push marker
      decoration = @editor.decorateMarker marker,
        type: 'overlay',
        item: @getCursorElement user

  destroyMarkers: ->
    @markers?.forEach (marker) =>
      marker.destroy()
    @markers = []

  getCursorElement: (user) ->
    element = document.createElement('div')
    element.setAttribute 'class', 'popover-list'
    element.setAttribute 'style',
      """
      background-color: #{user.color};
      display: block;
      padding: 3px;
      font-size: 12px;
      color: white;
      """
    element.textContent = user.displayName
    element

  updateCursorPosition: (event) ->
    @firebaseCursor.set(event.newBufferPosition)

  remove: ->
    @firebaseUserSelf.remove()
    @firebaseUsers.off()
    @firebaseContent.off()
    @subscriptions.dispose()
    @destroyMarkers()
    @emitter.emit 'did-destroy'

  onDidDestroy: (callback) ->
    @emitter.on 'did-destroy', callback
