###*
* @file SpriteStatus.coffee
* ステータス表示用スプライト
###

tm.define 'nz.SpriteStatus',
  superClass: tm.display.CanvasElement

  init: (@index,@character) ->
    @superInit()
    @setOrigin(0.0,0.0)

    @width          = 32 * 5
    @height         = 32 * 2.5
    @alpha          = 1.0
    @boundingType   = 'rect'
    @interactive    = true
    @checkHierarchy = true

    @fromJSON
      children:
        bg:
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
        name:
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
        attackMode:
          type:      'Label'
          fillStyle: 'black'
          align:     'left'
          baseline:  'top'
          x:         8
          y:         16
          originX:   @originX
          originY:   @originY
          fontSize:  10
        cost:
          type:      'Label'
          fillStyle: 'black'
          align:     'left'
          baseline:  'top'
          x:         8
          y:         24
          originX:   @originX
          originY:   @originY
          fontSize:  10
    
    #
    @on 'refreshStatus', (e) ->
      @attackMode.text = if @character.isAttackAction(e.turn) then 'Attack' else 'No'
      @cost.text = @character.ap - @character.getActionCost(e.turn)
