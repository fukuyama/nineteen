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

    @loadMap()
    return

  loadMap: ->
    unless phina.asset.AssetManager.get('json',@mapName)
      @one 'enterframe', ->
        assets = json:{}
        assets.json[@mapName] = "data/#{@mapName}.json"
        @loadAsset assets, @loadCharacter
    else
      @loadCharacter()
    return

  loadCharacter: ->
    unless phina.asset.AssetManager.get('json','character_001')
      @one 'enterframe', ->
        assets = json:{}
        assets.json['character_001'] = "data/character_001.json"
        @loadAsset assets, ->
          console.log 'end'
    return

  loadAsset: (assets,cb) ->
    @app.pushScene phina.game.LoadingScene assets: assets
    if cb?
      @one 'resume', cb
