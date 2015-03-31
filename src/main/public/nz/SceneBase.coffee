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

  fireAll: (e,param={}) ->
    if typeof e is 'string'
      e      = tm.event.Event(e)
      e.app  = @app
      e.$extend param
    @_dispatchEvent(e)
    return

  _dispatchEvent: (e,element=@) ->
    if element.hasEventListener(e.type)
      element.fire(e)
    for child in element.children
      @_dispatchEvent(e,child)
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
