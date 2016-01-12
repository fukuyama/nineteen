###*
* @file SceneBattleStart.coffee
* 戦闘開始
###

phina.define 'nz.SceneBattleStart',
  superClass: nz.SceneBase

  ###* 初期化
  * @classdesc 戦闘開始
  * @constructor nz.SceneBattleStart
  ###
  init: (param) ->
    {
      @mapId
      @characters
      @controlTeam
    } = param
    @superInit()
    @mapName = 'map_' + "#{@mapId}".paddingLeft(3,'0')
    console.log @mapName
    return
