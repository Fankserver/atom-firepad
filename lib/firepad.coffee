{CompositeDisposable} = require 'atom'
Crypto = require 'crypto'
Firebase = require 'firebase'
Firepad = require './firepad-lib'
ShareView = require './share-view'
ShareSetupView = require './sharesetup-view'

module.exports =
  config:
    firebaseUrl:
      type: 'string'
      default: 'https://atom-firepad.firebaseio.com'

  activate: (state) ->
    @shareview = new ShareView
    @shareSetupView = new ShareSetupView
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-text-editor', 'firepad:share': => @share()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'firepad:unshare': => @unshare()

    @subscriptions.add @shareSetupView.onDidConfirm (shareIdentifier) =>
      @shareIdentifier = shareIdentifier
      @setupShare()

  deactivate: ->
    @subscriptions.dispose()

  setupShare: ->
    hash = Crypto.createHash('sha256').update(@shareIdentifier).digest('base64')
    @firebase = new Firebase(atom.config.get('firepad.firebaseUrl')).child(hash)

    editor = atom.workspace.getActiveTextEditor()
    @firebase.once 'value', (snapshot) =>
      options = {sv_: Firebase.ServerValue.TIMESTAMP}
      if not snapshot.val() and editor.getText() isnt ''
        options.overwrite = true
      else
        editor.setText ''
      @firepad = Firepad.fromAtom @firebase, editor, options
      @shareview.show(@shareIdentifier)

  share: ->
    @shareSetupView.show()

  unshare: ->
    @shareview.detach()
    @firepad.dispose()
