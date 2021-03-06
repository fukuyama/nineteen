###*
* @file SceneMenu.coffee
* メニューシーン
###

SCREEN_W    = nz.system.screen.width
SCREEN_H    = nz.system.screen.height

phina.define 'nz.SceneMenu',
  superClass: phina.ui.MenuDialog

  init: (param) ->
    param = {
      self: @
      screenWidth:  SCREEN_W
      screenHeight: SCREEN_H
    }.$extend param
    @menuFunc  = (m.func for m in param.menu when m.func?)
    param.menuDescriptions = (m.description for m in param.menu when m.description?)
    param.menu = (m.name for m in param.menu when m.name?)
    @superInit(param)

    @box.setStrokeStyle nz.system.dialog.strokeStyle
    @box.setFillStyle   nz.system.dialog.fillStyle

    index = null
    @on 'menuselected', (e) ->
      index = e.selectIndex
      return
    @on 'menuclosed', (e) ->
      @menuFunc[index]?.call(param.self,index) if index?
      return

    @on 'menuopened', ->
      @_flag = false
      @on 'enterframe', (e) ->
        {app} = e
        kb = app.keyboard
        if kb.getKeyDown('up')
          @up()
        else if kb.getKeyDown('down')
          @down()
        else if kb.getKeyDown('enter')
          unless @_flag
            @_flag = true
            @closeDialog(@_selected)
        else if kb.getKeyDown('escape')
          unless @_flag
            @_flag = true
            @closeDialog(-1)
        return
      return

    @description.remove()
    @description = nz.SpriteHelpText().addChildTo @

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
    @dispatchEvent phina.event.Event('menuselect')
    return
