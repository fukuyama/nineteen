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

    @bgColor         = 'blanchedalmond'
    gaugebBrderColor = 'gray'

    form =
      children:
        bg:
          type:          'RoundRectangleShape'
          width:         @width
          height:        @height
          strokeStyle:   'black'
          fillStyle:     @bgColor
          lineWidth:     1
          shadowBlur:    1
          shadowOffsetX: 2
          shadowOffsetY: 2
          shadowColor:   'gray'
          originX:       @originX
          originY:       @originY
        name:
          type:          'Label'
          text:          @character.name
          fillStyle:     'black'
          align:         'left'
          baseline:      'top'
          x:             8
          y:             10
          originX:       @originX
          originY:       @originY
          fontSize:      8
        action:
          type:          'Label'
          fillStyle:     'black'
          align:         'left'
          baseline:      'top'
          x:             8
          y:             20
          originX:       @originX
          originY:       @originY
          fontSize:      8
        hpGauge:
          type:          'tm.ui.GlossyGauge'
          x:             8
          y:             38
          width:         @width - 16
          height:        6
          originX:       @originX
          originY:       @originY
          borderWidth:   1
          color:         'green'
          bgColor:       @bgColor
          borderColor:   gaugebBrderColor
          animationTime: 1000
          _maxValue:     @character.maxhp
        hpLabel:
          type:          'Label'
          fillStyle:     'black'
          align:         'left'
          baseline:      'top'
          x:             10
          y:             38 - 2
          originX:       @originX
          originY:       @originY
          fontSize:      8
          text:          'HP'
        spGauge:
          type:          'tm.ui.GlossyGauge'
          x:             8
          y:             50
          width:         @width - 16
          height:        6
          originX:       @originX
          originY:       @originY
          borderWidth:   1
          color:         'DarkSlateBlue'
          bgColor:       @bgColor
          borderColor:   gaugebBrderColor
          animationTime: 1000
          _maxValue:     @character.maxsp
        spLabel:
          type:          'Label'
          fillStyle:     'black'
          align:         'left'
          baseline:      'top'
          x:             10
          y:             50 - 2
          originX:       @originX
          originY:       @originY
          fontSize:      8
          text:          'SP'
    #if @detail
    #  form.children.apGauge =
    #    type:          'tm.ui.GlossyGauge'
    #    x:             8
    #    y:             48
    #    width:         @width - 16
    #    height:        4
    #    originX:       @originX
    #    originY:       @originY
    #    borderWidth:   1
    #    color:         'red'
    #    bgColor:       @bgColor
    #    borderColor:   gaugebBrderColor
    #    animationFlag: false
    #    _maxValue:     @character.maxap
    @fromJSON form

    @on 'refreshStatus', @refreshStatus

  refreshStatus: (param) ->
    {
      turn
    } = param

    @_refreshActionText turn

    @hpGauge.value = @character.hp
    @spGauge.value = @character.sp
    # @apGauge.value = ap if @detail

  _refreshActionText: (turn) ->
    text = 'Action: '
    if @detail
      ap = @character.getRemnantAp(turn)
      actions = []
      actions.push 'Attack' if @character.isAttackCommand(turn)
      actions.push 'Shot'   if @character.isShotCommand(turn)
      actions.push 'Move'   if @character.isMoveCommand(turn)
      text += actions.join(' & ')
      text += " (AP=#{ap})"
    else
      text += '???'
    @action.text = text
