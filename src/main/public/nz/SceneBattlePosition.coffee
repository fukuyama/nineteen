###*
* @file SceneBattlePosition.coffee
* 戦闘開始位置設定
###

MSGS   = nz.system.MESSAGES
DIRNUM = nz.system.DIRECTION_NUM

tm.define 'nz.SceneBattlePosition',
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

    @_keyDown  = null

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
    #@on 'map.pointingover', @_test

    @on 'enterframe'   , @createKeyboradHander()
    @on 'input_up'     , @cursorHandler
    @on 'input_down'   , @cursorHandler
    @on 'input_left'   , @cursorHandler
    @on 'input_right'  , @cursorHandler
    @on 'repeat_up'    , @cursorHandler
    @on 'repeat_down'  , @cursorHandler
    @on 'repeat_left'  , @cursorHandler
    @on 'repeat_right' , @cursorHandler
    @on 'input_enter'  , @inputEnter

  cursorHandler: (e) ->
    @mapSprite.fire e
    @_mapPointingover @mapSprite.cursor

  inputEnter: (e) ->
    @_mapPointingend @mapSprite.cursor

  _test: (e) ->
    @mapSprite.cursor.visible = true
    @mapSprite.clearBlink()
    for x in [0 ... @mapSprite.map.width]
      for y in [0 ... @mapSprite.map.height]
        if nz.system.ai['SampleAI'].calcDistance({x:e.mapx,y:e.mapy},{x:x,y:y}) <= 3
          @mapSprite.blink(x,y)
    return

  _start: ->
    for c in @mapSprite.characterSprites when not c.visible
      @_selectCharacter c
      @description MSGS.battle.position.setiing.format name:c.character.name
      return
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

  _openCharacterMenu: ->
    @mapSprite.clearBlink()
    @mapSprite.cursor.visible = false
    characters = []
    menu = []
    for team in @controlTeam
      for c in @members[team] when not c.visible
        characters.push c
        menu.push
          name: c.character.name
          func: ((i) -> @_selectCharacter(characters[i])).bind @
    @openMenuDialog(
      title: 'Character'
      menu: menu
    )

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
    @mapSprite.cursor.visible = true
    @character.visible = true
    @_setBattlePosition(@character,mapx,mapy)
    @character.applyPosition()
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
