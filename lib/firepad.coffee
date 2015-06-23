{CompositeDisposable} = require 'atom'
Crypto = require 'crypto'
Firebase = require 'firebase'
Firepad = require './firepad-lib'
ShareView = require './share-view'
ShareSetupView = require './sharesetup-view'

module.exports =
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
    @firebase = new Firebase('https://atom-firepad.firebaseio.com').child(hash)

    editor = atom.workspace.getActiveTextEditor()
    @firebase.once 'value', (snapshot) =>
      options = {sv_: Firebase.ServerValue.TIMESTAMP}
      if not snapshot.val() and editor.getText() not ''
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
