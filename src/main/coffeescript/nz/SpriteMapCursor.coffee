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

  setMapPosition: (param) ->
    return unless param?
    @mapx = param.mapx if param.mapx?
    @mapy = param.mapy if param.mapy?
    @x = param.x
    @y = param.y
    return

  cursorUp: ->
    @setMapPosition @getMapChip(@mapx,@mapy - 1)
    return

  cursorDown: ->
    @setMapPosition @getMapChip(@mapx,@mapy + 1)
    return

  cursorLeft: ->
    chip = @getMapChip(@mapx - 1,@mapy)
    unless chip?
      chip = @getMapChip(@mapx - 1,@mapy - 1)
    @setMapPosition chip
    return

  cursorRight: ->
    chip = @getMapChip(@mapx + 1,@mapy)
    unless chip?
      chip = @getMapChip(@mapx + 1,@mapy - 1)
    @setMapPosition chip
    return
