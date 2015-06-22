{CompositeDisposable} = require 'atom'
Crypto = require 'crypto'
Firebase = require 'firebase'
Firepad = require './firepad-lib'
FirepadView = require './firepad-view'
ShareView = require './share-view'

module.exports =
  activate: (state) ->
    @firepadView = new FirepadView
    @shareview = new ShareView

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'firepad:share': => @share()
    # @subscriptions.add atom.commands.add 'atom-text-editor', 'firepad:unshare': => @unshare()
    @subscriptions.add @firepadView.onDidConfirm (shareIdentifier) =>
      @shareIdentifier = shareIdentifier
      @setupShare()

  deactivate: ->
    @subscriptions.dispose()

  share: ->
    @firepadView.share()

  setupShare: ->
    hash = Crypto.createHash('sha256').update(@shareIdentifier).digest('base64');
    @firebase = new Firebase('https://atom-firepad.firebaseio.com').child(hash);

    editor = atom.workspace.getActiveTextEditor()
    @firebase.once 'value', (snapshot) =>
      options = {sv_: Firebase.ServerValue.TIMESTAMP}
      if !snapshot.val() && editor.getText() != ''
        options.overwrite = true
      else
        editor.setText ''
      @firepad = Firepad.fromAtom @firebase, editor, options
      @shareview.show()

  unshare: ->
    @firepad.dispose()
