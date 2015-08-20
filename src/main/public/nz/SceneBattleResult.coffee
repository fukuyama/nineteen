###*
* @file SceneBattleResult.coffee
* 戦闘結果の処理
###

SCREEN_W    = nz.system.screen.width
SCREEN_H    = nz.system.screen.height
MBR         = nz.system.messages.battle.result

tm.define 'nz.SceneBattleResult',
  superClass: nz.SceneBase

  init: (param) ->
    @superInit()
    {
      @mapSprite
      @data
    } = param
    @data.replay = undefined

    @setOrigin(0.0,0.0)

    @width          = SCREEN_W - 32 * 2
    @height         = SCREEN_H - 32 * 2
    @fillStyle      = nz.system.dialog.fillStyle
    @strokeStyle    = nz.system.dialog.strokeStyle
    @boundingType   = 'rect'
    @interactive    = true
    @checkHierarchy = true

    @one 'enterframe', @setup

  setup: ->
    form =
      children:
        bg:
          type:          'RoundRectangleShape'
          x:             32
          y:             32
          width:         @width
          height:        @height
          strokeStyle:   @strokeStyle
          fillStyle:     @fillStyle
          #lineWidth:     1
          #shadowBlur:    1
          #shadowOffsetX: 2
          #shadowOffsetY: 2
          #shadowColor:   'gray'
          originX:       @originX
          originY:       @originY
        message:
          type:      'Label'
          fillStyle: 'black'
          align:     'left'
          baseline:  'top'
          x:         32 + 8
          y:         32 + 10
          originX:   @originX
          originY:   @originY
          fontSize:  8
    form.children.message.text =
      if @data.result.winner?
        'Winner! ' + @data.result.winner.name
      else
        'Draw!!! ' + (o.name for o in @data.result.draw).join ','

    @fromJSON form

    @setupKeyboradHander()
    @on 'pointingend', @_openBattleEndMenu
    @on 'input_enter', @_openBattleEndMenu

  _startReplay: ->
    @data.replay =
      start: 1
      end: @data.turn
    @app.popScene()
    return

  _startRematch: ->
    return

  _endBattle: ->
    @app.popScene()
    return

  _exitGame: ->
    nz.system.restart()
    return

  _openBattleEndMenu: ->
    @openMenuDialog
      self: @
      title: 'Battle End'
      menu: [
        {name: 'Replay',     func: @_startReplay  , description: MBR.replay    }
        #{name: 'Rematch',    func: @_startRematch , description: MBR.rematch   }
        #{name: 'End Battle', func: @_endBattle    , description: MBR.end_battle}
        {name: 'Exit Game',  func: @_exitGame     , description: MBR.exit_game }
        {name: 'Close Menu',                        description: MBR.close_menu}
      ]
    return
