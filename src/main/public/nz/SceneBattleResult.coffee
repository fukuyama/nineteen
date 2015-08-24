###*
* @file SceneBattleResult.coffee
* 戦闘結果の処理
###

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

    @width          = nz.system.screen.width  - 32 * 2
    @height         = nz.system.screen.height - 32 * 2
    @fillStyle      = nz.system.dialog.fillStyle
    @strokeStyle    = nz.system.dialog.strokeStyle
    @boundingType   = 'rect'
    @interactive    = true
    @checkHierarchy = true

    @on 'enter', @setup

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
          originX:       @originX
          originY:       @originY
    #text =
    #  if @data.result.winner?
    #    'Winner! ' + @data.result.winner.name
    #  else
    #    'Draw!!! ' + (o.name for o in @data.result.draw).join ','

    @fromJSON form

    x = 2
    y = 2
    for team in @data.teams
      text = @textShape(x,y,team)
      cx = x
      cy = text.y + 16
      for c in @mapSprite.characterSprites
        c = c.character
        if c.team is team
          text = @textShape(cx,cy,c.name)
          cx += @width / 3
      y += @height / 2

    @setupKeyboradHander()
    @on 'pointingend', @_openBattleEndMenu
    @on 'input_enter', @_openBattleEndMenu

  textShape: (x,y,text) ->
    t = tm.display.TextShape(
      text: text
      fontSize: 14
    ).addChildTo @bg
    t.x = x + t.width / 2
    t.y = y + t.height / 2
    return t

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
    msg = nz.system.messages.battle.result
    @openMenuDialog
      self: @
      title: 'Battle End'
      menu: [
        {name: 'Replay',     func: @_startReplay  , description: msg.replay    }
        #{name: 'Rematch',    func: @_startRematch , description: msg.rematch   }
        #{name: 'End Battle', func: @_endBattle    , description: msg.end_battle}
        {name: 'Exit Game',  func: @_exitGame     , description: msg.exit_game }
        {name: 'Close Menu',                        description: msg.close_menu}
      ]
    return
