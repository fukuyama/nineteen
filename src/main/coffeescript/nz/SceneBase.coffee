###*
* @file SceneBase.coffee
* シーンベース
###

phina.define 'nz.SceneBase',
  superClass: phina.display.CanvasScene

  init: (options) ->
    @superInit(options)
    @on 'resume', ->
      @_description?.show()
      return
    return

  popMessage: (param) ->
    {
      message
      popwait
    } = {
      message: ''
      popwait: 500
    }.$extend param
    scene = nz.ScenePopMessage
      message:  message
      width:    @width / 2
      height:   50
      start:    [@gridX.center(),-25]
      center:   [@gridX.center(),@gridY.center(),500]
      end:      [@gridX.center(),@height + 25,500]
      duration: 1000
      fillStyle:   nz.system.dialog.fillStyle
      strokeStyle: nz.system.dialog.strokeStyle
      popwait:  popwait
    @descriptionOff()
    @app.pushScene scene

  openMenuDialog: (param) ->
    menu = MenuScene(param.$safe nz.system.screen)
    @descriptionOff()
    @app.pushScene menu
    return menu

  descriptionOff: ->
    @_description?.hide()
    return

  setDescription: (text) ->
    @description(text)
    return
  description: (text) ->
    unless @_description?
      @_description = nz.SpriteHelpText().addChildTo @
    @_description.text = text

  setupKeyboradHander: ->
    @on 'enterframe', @createKeyboradHander()
    return

  createKeyboradHander: ->
    eventKeys      = ['up','down','left','right','enter','escape']
    repeatCount    = 0
    repeatDelay    = 10
    repeatIntarval = 0

    return (e) ->
      app = @app ? e.app
      kb = app.keyboard
      for key in eventKeys when kb.getKeyDown(key)
        repeatCount = 0
        @flare('input_' + key)

      for key in eventKeys when kb.getKey(key)
        if repeatDelay < repeatCount++
          @flare('repeat_' + key)
          repeatCount -= repeatIntarval

  setupCursorHandler: (handler) ->
    console.log 'setupCursorHandler'
    for k in ['up','down','left','right']
      @on 'input_'  + k, handler
      @on 'repeat_' + k, handler
    return

  loadAsset: (assets,cb) ->
    for type,data of assets
      for key,val of data
        if phina.asset.AssetManager.get(type,key)
          delete data[key]
      if Object.keys(data).length == 0
        delete assets[type]
    if Object.keys(assets).length == 0
      @one 'enterframe', cb
    else
      @one 'resume', cb
      @one 'enterframe', -> @app.pushScene phina.game.LoadingScene assets: assets
    return
