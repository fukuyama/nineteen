###*
* @file SpriteMapCursor.coffee
* マップカーソル
###

MAP_CHIP_W = nz.system.map.chip.width
MAP_CHIP_H = nz.system.map.chip.height

phina.define 'nz.SpriteMapCursor',
  superClass: phina.display.RectangleShape

  ###* 初期化
  * @classdesc マップカーソル
  * @constructor nz.SpriteMapCursor
  ###
  init: (options={}) ->
    @superInit {
      width:        MAP_CHIP_W
      height:       MAP_CHIP_H
      stroke:       'red'
      strokeWidth:  3
      visible:      true
      cornerRadius: 5
      fill:         null
      backgroundColor: 'transparent'
    }.$extend options
    @mapx = 0
    @mapy = 0

    @on 'input_up'     , @cursorUp
    @on 'input_down'   , @cursorDown
    @on 'input_left'   , @cursorLeft
    @on 'input_right'  , @cursorRight
    @on 'repeat_up'    , @cursorUp
    @on 'repeat_down'  , @cursorDown
    @on 'repeat_left'  , @cursorLeft
    @on 'repeat_right' , @cursorRight

    @on 'startBattlePhase', @show
    @on 'endBattlePhase'  , @hide

    return

  setMapPosition: (mapx,mapy) ->
    return false unless @parent?
    chip = @parent.getMapChip mapx,mapy
    return false unless chip?
    @mapx = chip.mapx if chip.mapx?
    @mapy = chip.mapy if chip.mapy?
    @x = chip.x
    @y = chip.y
    return true

  cursorUp: ->
    @setMapPosition @mapx,@mapy - 1
    return

  cursorDown: ->
    @setMapPosition @mapx,@mapy + 1
    return

  cursorLeft: ->
    unless @setMapPosition(@mapx - 1,@mapy)
      @getMsetMapPositionapChip(@mapx - 1,@mapy - 1)
    return

  cursorRight: ->
    unless @setMapPosition(@mapx + 1,@mapy)
      @setMapPosition(@mapx + 1,@mapy - 1)
    return
