###*
* @file SceneBase.coffee
* シーンベース
###

SCREEN_W    = nz.system.screen.width
SCREEN_H    = nz.system.screen.height

tm.define 'nz.SceneBase',
  superClass: tm.app.Scene

  init: ->
    @superInit()
    return

  openMenuDialog: (_param) ->
    param = {
      screenWidth:  SCREEN_W
      screenHeight: SCREEN_H
    }.$extend _param
    menuFunc   = (m.func for m in param.menu when m.func?)
    param.menu = (m.name for m in param.menu when m.name?)
    dlg = tm.ui.MenuDialog(param)
    dlg.on 'menuclosed', (e) -> menuFunc[e.selectIndex]?.call(null,e.selectIndex)
    dlg.box.setStrokeStyle nz.system.dialog.strokeStyle
    dlg.box.setFillStyle   nz.system.dialog.fillStyle

    @app.pushScene dlg
    return dlg

  description: (text) ->
    unless @_description
      @_description = tm.display.Label(
        ''
        14
      ).addChildTo   @
        .setAlign    'center'
        .setBaseline 'middle'
        .setPosition SCREEN_W / 2, SCREEN_H - 10
    @_description.text = text

  createKeyboradHander: ->
    eventKeys      = ['up','down','left','right','enter']
    #eventUpKeys    = []
    repeatCount    = 0
    repeatDelay    = 10
    repeatIntarval = 0

    return ->
      kb = @app.keyboard
      for key in eventKeys when kb.getKeyDown(key)
        repeatCount = 0
        @fire tm.event.Event('input_' + key)

      for key in eventKeys when kb.getKey(key)
        if repeatDelay < repeatCount++
          @fire tm.event.Event('repeat_' + key)
          repeatCount -= repeatIntarval

      #for key in eventUpKeys when kb.getKeyUp(key)
      #  repeatCount = 0
      #  @fire tm.event.Event('input_' + key + '_up')
