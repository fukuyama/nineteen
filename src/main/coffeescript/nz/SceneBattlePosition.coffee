###*
* @file SceneBattlePosition.coffee
* 戦闘開始位置設定
###

MSGS   = nz.system.messages
DIRNUM = nz.system.direction_num

phina.define 'nz.SceneBattlePosition',
  superClass: nz.SceneBase

  init: (param) ->
    @superInit()
    {
      @mapSprite
      @controlTeam
    } = param

    @otherTeam = []

    @teamArea  = {}
    @members   = {}

    areaIndex  = 0
    for c in @mapSprite.characterSprites
      team = c.character.team
      unless @members[team]?
        @members[team]  = []
        @teamArea[team] = @mapSprite.map.start.area[areaIndex].clone()
        @otherTeam.push team unless @controlTeam.contains team
        areaIndex += 1
      @members[team].push c

    # CPU側の位置設定
    for team in @otherTeam
      area    = @teamArea[team]
      friends = (m.character for m in @members[team])
      for m,i in @members[team]
        c = m.character
        p = nz.system.ai[c.ai.name]?.setupBattlePosition(
          character: c
          friends:   friends
          area:      area
        )
        p = area[i] unless p?
        @_setBattlePosition(m,p[0],p[1])
        m.applyPosition()

    @on 'map.pointingover', @_mapPointingover
    @on 'map.pointingend',  @_mapPointingend
    @on 'enter',            @_start

    @setupKeyboradHander()
    @on 'input_enter'  , @inputEnter
    @setupCursorHandler @cursorHandler

  cursorHandler: (e) ->
    @mapSprite.fire e
    @_mapPointingover @mapSprite.cursor

  inputEnter: (e) ->
    @_mapPointingend @mapSprite.cursor

  _start: ->
    for c in @mapSprite.characterSprites when (not c.visible) and @controlTeam.contains c.character.team
      @_selectCharacter c
      @description MSGS.battle.position.setiing.format name:c.character.name
      return
    @_end()
    return

  _end: ->
    mapycenter = @mapSprite.map.width / 2
    for c in @mapSprite.characterSprites
      c.visible = true
      if c.mapy < mapycenter
        c.character.direction = DIRNUM.DOWN
        c.setDirection(DIRNUM.DOWN)
      else
        c.character.direction = DIRNUM.UP
        c.setDirection(DIRNUM.UP)
    @mapSprite.clearBlink()
    @one 'enterframe', -> @app.popScene()
    return

  _selectCharacter: (@character) ->
    @mapSprite.clearBlink()
    for m in @teamArea[@character.character.team]
      if @mapSprite.findCharacter(m[0],m[1]).length == 0
        @mapSprite.blink(m[0],m[1])

  _setBattlePosition: (c,mapx,mapy) ->
    c.setMapPosition mapx,mapy
    if c.mapy < @mapSprite.map.width / 2
      c.setDirection DIRNUM.DOWN
    else
      c.setDirection DIRNUM.UP
    return

  _mapPointingover: (param) ->
    {
      mapx
      mapy
    } = param
    @_setBattlePosition(@character,mapx,mapy)
    @character.applyPosition()
    @mapSprite.cursor.visible = true
    @character.visible = true
    return

  _mapPointingend: (param) ->
    {
      mapx
      mapy
    } = param
    if @mapSprite.isBlink(mapx,mapy)
      @_mapPointingover(param)
      for team in @controlTeam
        for c in @members[team] when not c.visible
          @_start()
          return
      @_end()
    return
