###*
* @file SceneBattlePosition.coffee
* 戦闘開始位置設定
###

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
      members = (m.character for m in @members[team])
      for member,i in @members[team]
        c = member.character
        p = nz.system.ai[c.ai]?.setupBattlePosition(
          character: c
          members:   members
          area:      area
        )
        p = area[i] unless p?
        member.character.mapx = p[0]
        member.character.mapy = p[1]
        member.setMapPosition(p[0],p[1])

    @on 'map.pointingover', @_mapPointingover
    @on 'map.pointingend',  @_mapPointingend
    @on 'enter',            @_openCharacterMenu

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

  _setMapPosition: (mapx,mapy) ->
    if @mapSprite.isBlink(mapx,mapy)
      @character.character.mapx = mapx
      @character.character.mapy = mapy
      @character.setMapPosition(mapx,mapy).setVisible(true)
    return

  _mapPointingover: (e) ->
    @mapSprite.cursor.visible = true
    @_setMapPosition(e.mapx,e.mapy)
    return

  _mapPointingend: (e) ->
    @_setMapPosition(e.mapx,e.mapy)
    for team in @controlTeam
      for c in @members[team] when not c.visible
        @_openCharacterMenu()
        return
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
