{CompositeDisposable} = require 'atom'
FirepadShare = require './firepad-share'


module.exports =
  config:
    firebaseUrl:
      type: 'string'
      default: 'https://atom-firepad.firebaseio.com'

  shareStack: []

  activate: (state) ->
    ShareSetupView = require './views/share-setup'
    @shareSetupView ?= new ShareSetupView

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-text-editor', 'firepad:share': => @share()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'firepad:unshare': => @unshare()
    @subscriptions.add atom.commands.add 'atom-text-editor', 'firepad:copyid': => @copyid()

    @subscriptions.add atom.workspace.observeActivePaneItem => @updateShareView()

    @subscriptions.add @shareSetupView.onDidConfirm (shareIdentifier) => @createShare(shareIdentifier)

    TabIcon = require "./firepad-tab-icon"
    @tabIcon ?= new TabIcon


  consumeStatusBar: (statusBar) ->
    ShareStatusBarView = require './views/share-status-bar'
    @shareStatusBarView ?= new ShareStatusBarView()
    @shareStatusBarTile = statusBar.addRightTile(item: @shareStatusBarView, priority: 100)

  deactivate: ->
    @subscriptions.dispose()

    @statusBarTile?.destroy()
    @statusBarTile = null

  createShare: (shareIdentifier) ->
    if shareIdentifier
      editor = atom.workspace.getActiveTextEditor()

      editorIsShared = false
      for share in @shareStack
        if share.getEditor() is editor
          editorIsShared = true

      if not editorIsShared
        share = new FirepadShare(editor, shareIdentifier)
        @subscriptions.add share.onDidDestroy => @destroyShare(share)

        @shareStack.push share
        @updateShareView()

      else
        atom.notifications.addError('Pane is shared')

    else
      atom.notifications.addError('No session key set')

  destroyShare: (share) ->
    shareStackIndex = @shareStack.indexOf share
    if shareStackIndex isnt -1
      @shareStack.splice shareStackIndex, 1
      @updateShareView()

    else
      console.error share, 'not found'

  updateShareView: ->
    if @shareStatusBarView
      editor = atom.workspace.getActiveTextEditor()

      editorIsShared = false
      for share in @shareStack
        if share.getEditor() is editor
          editorIsShared = true
          @shareStatusBarView.show(share.getShareIdentifier())

      if not editorIsShared
        @shareStatusBarView.hide()

  share: ->
    @shareSetupView.show()

  unshare: ->
    editor = atom.workspace.getActiveTextEditor()

    #remove the icon
    @tabIcon.processPath editor.getPath(), true

    editorIsShared = false
    for share in @shareStack
      if share.getEditor() is editor
        editorIsShared = true
        share.remove()
        atom.notifications.addInfo("Unhare the file.")
        break

    if not editorIsShared
      atom.notifications.addError('Pane is not shared')

  copyid: ->
    editor = atom.workspace.getActiveTextEditor()

    for share in @shareStack
      if share.getEditor() is editor
        atom.clipboard.write(share.getShareIdentifier())
        atom.notifications.addInfo("Copy the shareIdentifier \"" + share.getShareIdentifier() + "\" to clipboard.")
