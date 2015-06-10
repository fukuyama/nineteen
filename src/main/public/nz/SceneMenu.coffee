###*
* @file SceneMenu.coffee
* メニューシーン
###

SCREEN_W    = nz.system.screen.width
SCREEN_H    = nz.system.screen.height

tm.define 'nz.SceneMenu',
  superClass: tm.ui.MenuDialog

  init: (param) ->
    param = {
      screenWidth:  SCREEN_W
      screenHeight: SCREEN_H
    }.$extend param
    @menuFunc  = (m.func for m in param.menu when m.func?)
    param.menu = (m.name for m in param.menu when m.name?)
    param.menuDesctiptions = (m.desctiption for m in param.menu when m.desctiption?)
    @superInit(param)

    @box.setStrokeStyle nz.system.dialog.strokeStyle
    @box.setFillStyle   nz.system.dialog.fillStyle

    index = null
    @on 'menuselected', (e) ->
      index = e.selectIndex
      return
    @on 'exit', (e) ->
      @menuFunc[index]?.call(@,index) if index?
      return

    @on 'enterframe', (e) ->
      {app} = e
      kb = app.keyboard
      if kb.getKeyDown('up')
        @up()
      else if kb.getKeyDown('down')
        @down()
      else if kb.getKeyDown('enter')
        @closeDialog(@_selected)
      return

    return

  up: ->
    @setIndex @_selected - 1
    return
  down: ->
    @setIndex @_selected + 1
    return

  setIndex: (i) ->
    @_selected = (i + @menu.length) % @menu.length
    @selectValue = @menu[@_selected]
    @selectIndex = @_selected
    @dispatchEvent tm.event.Event('menuselect')
    return
