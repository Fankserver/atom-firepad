
{CompositeDisposable} = require 'atom'
{TextEditorView} = require 'atom-space-pen-views'
Crypto = require 'crypto'
{View} = require 'space-pen'

Firebase = require 'firebase'
Firepad = require './firepad-lib'

class ShareView extends View
  @content: ->
    @div class: 'firepad overlay from-bottom', =>
      @div 'This file is being shared', class: 'message'

  show: ->
    workspaceView = atom.views.getView(atom.workspace)
    workspaceView.append(this)

module.exports =
class FirepadView extends View
  @activate: -> new FirepadView

  @content: ->
    @div class: 'firepad overlay from-top mini', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'message', outlet: 'message'

  detaching: false

  initialize: ->
    console.log('foo')
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'firepad:share': => @share()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'firepad:unshare': => @unshare()

    @miniEditor.hiddenInput.on 'focusout', => @detach() unless @detaching
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @detach()

    @miniEditor.preempt 'textInput', (e) =>
      false unless e.originalEvent.data.match(/[a-zA-Z0-9\-]/)

  detach: ->
    return unless @hasParent()
    @detaching = true
    @miniEditor.setText('')
    super
    @detaching = false

  share: ->
    if editor = atom.workspace.getActiveEditor()
      workspaceView = atom.views.getView(atom.workspace)
      workspaceView.append(this)
      randomString = Math.random().toString(36).slice(2, 10)
      @miniEditor.setText(randomString)
      @message.text('Enter a string to identify this share session')
      @miniEditor.focus()

  confirm: ->
    shareId = @miniEditor.getText()
    hash = Crypto.createHash('sha256').update(shareId).digest('base64');
    @detach()
    @ref = new Firebase('https://atom-firepad.firebaseio.com').child(hash);

    editor = atom.workspace.getActiveEditor()
    @ref.once 'value', (snapshot) =>
      options = {sv_: Firebase.ServerValue.TIMESTAMP}
      if !snapshot.val() && editor.getText() != ''
        options.overwrite = true
      else
        editor.setText ''
      @pad = Firepad.fromAtom @ref, editor, options
      @view = new ShareView()
      @view.show()

  unshare: ->
    @pad.dispose()
    @view.detach()
