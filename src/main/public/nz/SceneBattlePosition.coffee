###*
* @file SceneBattlePosition.coffee
* 戦闘開始位置設定
###

tm.define 'nz.SceneBattlePosition',
  superClass: nz.SceneBase

  init: (param) ->
    @superInit()
    {
      @mapSprite
      @controlTeam
    } = param

    areaIndex  = 0
    @otherTeam = []
    @teamArea  = {}
    @members   = {}
    for c in @mapSprite.characterSprites
      team = c.character.team
      unless @members[team]?
        @members[team]  = []
        @teamArea[team] = @mapSprite.map.start.area[areaIndex]
        @otherTeam.push team unless @controlTeam.contains team
        areaIndex += 1
      @members[team].push c

    # CPU側の位置設定
    for team in @otherTeam
      area    = @teamArea[team]
      members = (m.character for m in @members[team])
      for member in @members[team]
        c = member.character
        nz.system.ai[c.ai]?.setupBattlePosition(c,members,area)

    @on 'map.pointingover', @mapPointingover
    @on 'map.pointingend',  @mapPointingend
    @on 'enter',            @openCharacterMenu

  openCharacterMenu: ->
    @mapSprite.clearBlink()
    @mapSprite.cursor.visible = false
    characters = []
    menu = []
    for team in @controlTeam
      for c in @members[team] when not c.visible
        characters.push c
        menu.push
          name: c.character.name
          func: ((i) -> @selectCharacter(characters[i])).bind @
    @openMenuDialog(
      title: 'Character Member'
      menu: menu
    )

  selectCharacter: (@character) ->
    @mapSprite.clearBlink()
    for m in @teamArea[@character.character.team]
      if @mapSprite.findCharacter(m[0],m[1]).length == 0
        @mapSprite.blink(m[0],m[1])

  mapPointingover: (e) ->
    @mapSprite.cursor.visible = true
    if @mapSprite.isBlink(e.mapx,e.mapy)
      @character.setMapPosition(e.mapx,e.mapy).setVisible(true)
    return

  mapPointingend: (e) ->
    if @mapSprite.isBlink(e.mapx,e.mapy)
      @character.setMapPosition(e.mapx,e.mapy).setVisible(true)
    for team in @controlTeam
      for c in @members[team]
        unless c.visible
          @openCharacterMenu()
          return
    @mapSprite.clearBlink()
    @one 'enterframe', -> @app.popScene()
    return
