###*
* @file SpriteStatus.coffee
* ステータス表示用スプライト
###

DIRECTIONS = nz.system.character.directions

tm.define 'nz.SpriteStatus',
  superClass: tm.display.CanvasElement

  init: (param) ->
    {
      @index
      @character
      @characterSprite
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
    @bgColor        = 'blanchedalmond'

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
        name: @_label
          text:          @character.name
          fontSize:      8
          fillStyle:     'black'
          stroke:        false
          x:             8
          y:             10
        action: @_label
          text:          ''
          fontSize:      8
          fillStyle:     'black'
          stroke:        false
          x:             8
          y:             20
        hpGauge: @_gauge
          y:             38
          color:         'Green'
          _maxValue:     @character.maxhp
        spGauge: @_gauge
          y:             50
          color:         'DarkSlateBlue'
          _maxValue:     @character.maxsp
        hpLabel: @_label
          text:          'HP'
          fontSize:      12
          x:             10
          y:             38 - 6
        spLabel: @_label
          text:          'SP'
          fontSize:      12
          x:             10
          y:             50 - 6
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

    @sprite = tm.display.AnimationSprite(@characterSprite.ss).addChildTo @
    @sprite.x = @width - 40
    @sprite.y = 10
    @sprite.setScale(0.5,0.5)
    @sprite.setOrigin(0.0,0.0)

    @on 'refreshStatus', @refreshStatus

    @eventHandler = nz.EventHandlerBattle()
    @on 'pointingend', -> @eventHandler.selectStatus(status:@)

  _gauge: (param) ->
    {
      type:          'tm.ui.GlossyGauge'
      x:             8
      y:             0
      width:         @width - 16
      height:        6
      originX:       @originX
      originY:       @originY
      borderWidth:   1
      color:         'green'
      bgColor:       @bgColor
      borderColor:   'gray'
      animationTime: 1000
    }.$extend param

  _label: (param) ->
    {
      type:          'Label'
      fillStyle:     'white'
      strokeStyle:   'black'
      lineWidth:     2
      stroke:        true
      align:         'left'
      baseline:      'top'
      originX:       @originX
      originY:       @originY
      fontSize:      12
      text:          'null'
    }.$extend param

  refreshStatus: (param) ->
    {
      turn
    } = param

    @sprite.gotoAndPlay DIRECTIONS[@characterSprite.direction].name

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
