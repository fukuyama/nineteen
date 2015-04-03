###*
* @file SpriteStatus.coffee
* ステータス表示用スプライト
###

tm.define 'nz.SpriteStatus',
  superClass: tm.display.CanvasElement

  init: (param) ->
    {
      @index
      @character
      @detail
    } = param
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
        action:
          type:      'Label'
          fillStyle: 'black'
          align:     'left'
          baseline:  'top'
          x:         8
          y:         16
          originX:   @originX
          originY:   @originY
          fontSize:  10
    
    #
    @on 'refreshStatus', (e) ->
      {
        turn
      } = e
      if @detail
        actions = []
        actions.push 'Attack' if @character.isAttackAction(turn)
        actions.push 'Shot'   if @character.isShotAction(turn)
        actions.push 'Move'   if @character.isMoveAction(turn)
        text = actions.join('&')
        text += "(#{@character.getActionCost(turn)}/#{@character.ap})"
        @action.text = text
