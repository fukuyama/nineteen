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

    @fromJSON form

    y = 2
    for team in @data.teams
      x = 2
      @textShape(x,y,team).addChildTo @bg
      for cs in @mapSprite.characterSprites
        if cs.character.team is team
          @_charaResult(x,y + 18,cs).addChildTo @bg
          x += @width / 3 - 1
      y += @height / 2 - 1

    @setupKeyboradHander()
    @on 'pointingend', @_openBattleEndMenu
    @on 'input_enter', @_openBattleEndMenu
    @on 'input_escape', ->
      @bg.visible = not @bg.visible
      return

  _charaResult: (x,y,cs) ->
    o = tm.display.CanvasElement().setOrigin(0,0)
    o.x = x
    o.y = y
    ch = cs.character
    co = cs.counter
    pd = 16
    em = 16
    cx = pd + 2
    cy = 0
    cw = @width / 3 - pd * 2
    o.addChild @textShape(cx,cy,ch.name)
    for {k,v} in [
      {k:'kill:'         , v:co.kill.length}
      {k:'dead:'         , v:co.dead}
      {k:'attack damage:', v:co.weapon.atk.damage.total}
      {k:'shot damage:'  , v:co.ballet.atk.damage.total}
    ]
      cy += em
      o.addChild @textLabel(cx     ,cy,k)
      o.addChild @textLabel(cx + cw,cy,v,'right')
    return o

  textShape: (x,y,text) ->
    o = tm.display.TextShape
      text: text
      fontSize: 14
    o.x = x + o.width / 2
    o.y = y + o.height / 2
    return o
  textLabel: (x,y,text,align='left') ->
    o = tm.display.Label(
      text
      14
    )
    o.fillStyle = 'rgba(0,0,0,1.0)'
    o.align     = align
    o.baseline  = 'top'
    o.x = x
    o.y = y
    return o


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
