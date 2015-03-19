###*
* @file SpriteStatus.coffee
* ステータス表示用スプライト
###

tm.define 'nz.SpriteStatus',
  superClass: tm.display.CanvasElement

  init: (param={}) ->
    {
      @character
    } = param
    @superInit()

    @width  = 32 * 5
    @height = 32 * 2.5
    @setOrigin 0.0,0.0

    @setAlpha 0.2

    @fromJSON
      children: [
        {
          type:          'RoundRectangleShape'
          width:         @width
          height:        @height
          strokeStyle:   'black'
          fillStyle:     'blanchedalmond'
          shadowBlur:    1
          shadowOffsetX: 2
          shadowOffsetY: 2
          shadowColor:   'gray'
          originX:       @originX
          originY:       @originY
        }
        {
          type:      'Label'
          text:      @character.name
          fillStyle: 'black'
          align:     'left'
          baseline:  'top'
          x:         8
          y:         8
          originX:   @originX
          originY:   @originY
          fontSize:  10
        }
      ]
