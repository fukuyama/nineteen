###*
* @file SceneBase.coffee
* シーンベース
###

SCREEN_W = nz.system.screen.width
SCREEN_H = nz.system.screen.height
CENTER_X = SCREEN_W / 2
CENTER_Y = SCREEN_H / 2

tm.define 'nz.SceneBase',
  superClass: tm.app.Scene

  init: ->
    @superInit()
    @on 'resume', ->
      @_description?.show()
      return
    return

  popMessage: (param) ->
    {message} = param
    scene = nz.ScenePopMessage
      message:  message
      width:    SCREEN_W / 2
      height:   50
      start:    [CENTER_X,-25]
      center:   [CENTER_X,CENTER_Y,500]
      end:      [CENTER_X,SCREEN_H + 25,500]
      duration: 1000
      fillStyle:   nz.system.dialog.fillStyle
      strokeStyle: nz.system.dialog.strokeStyle
      popwait:  500
    @descriptionOff()
    @app.pushScene scene

  openMenuDialog: (param) ->
    dlg = nz.SceneMenu(param)
    @descriptionOff()
    @app.pushScene dlg
    return dlg

  descriptionOff: ->
    @_description?.hide()
    return

  description: (text) ->
    unless @_description?
      @_description = nz.SpriteHelpText().addChildTo @
    @_description.text = text

  setupKeyboradHander: ->
    @on 'enterframe', @createKeyboradHander()
    return

  createKeyboradHander: ->
    eventKeys      = ['up','down','left','right','enter']
    repeatCount    = 0
    repeatDelay    = 10
    repeatIntarval = 0

    return (e) ->
      app = @app ? e.app
      kb = app.keyboard
      for key in eventKeys when kb.getKeyDown(key)
        repeatCount = 0
        @fire tm.event.Event('input_' + key)

      for key in eventKeys when kb.getKey(key)
        if repeatDelay < repeatCount++
          @fire tm.event.Event('repeat_' + key)
          repeatCount -= repeatIntarval

  setupCursorHandler: (handler) ->
    for k in ['up','down','left','right']
      @on 'input_'  + k, handler
      @on 'repeat_' + k, handler
    return
