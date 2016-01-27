###*
* @file SceneTitleMenu.coffee
* タイトルシーン
###

phina.define 'nz.SceneTitleMenu',
  superClass: nz.SceneBase

  ###* 初期化
  * @classdesc タイトルシーンクラス
  * @constructor nz.SceneTitleMenu
  ###
  init: (options) ->
    @superInit(options)

    @one 'enter', ->
      @_main_menu()
      return

    #@on 'resume', ->
    #  @_sample_game()
    #  return

    return

  _main_menu: ->
    menus = [{
    #  name: 'New Game'
    #  description: '新しいゲームをはじめる'
    #  func: @_new_game
    #},{
    #  name: 'Sample Game'
    #  description: 'サンプルゲームをはじめる'
    #  func: @_sample_game
    #},{
      text: 'Debug Game'
      description: 'デバッグゲームをはじめる'
      fn: @_debug_game.bind @
    },{
      text: 'Load Game'
      description: '保存したゲームをはじめる'
      fn: @_load_game.bind @
    },{
      text: 'Option'
      description: 'ゲームオプション'
      fn: @_option.bind @
    }]
    @openMenuDialog
      title: 'title'
      menus: menus

  ###* 新しいゲームを開始
  * @memberof nz.SceneTitleMenu#
  ###
  _new_game: ->
    @app.replaceScene nz.SceneBattle(
      mapId: 1
      controlTeam: ['teamA']
      characters: [
        {text:'キャラクター1',team:'teamA'}
        {text:'キャラクター2',team:'teamA'}
        {text:'キャラクター3',team:'teamA'}
        {text:'キャラクター4',team:'teamB'}
        {text:'キャラクター5',team:'teamB'}
        {text:'キャラクター6',team:'teamB'}
      ]
    )
    return

  ###* ゲームをロード
  * @memberof nz.SceneTitleMenu#
  ###
  _load_game: ->
    console.log 'load game'
    return

  ###* システムオプション
  * @memberof nz.SceneTitleMenu#
  ###
  _option: ->
    console.log 'option'
    return

  ###* 新しいゲームを開始
  * @memberof nz.SceneTitleMenu#
  ###
  _sample_game: ->
    menu = [{
      text: 'Player vs Computer'
      description: 'プレイヤー 対 コンピューター'
      func: -> @_sample_game_2 true
    },{
      text: 'Computer vs Computer'
      description: 'コンピューター 対 コンピューター'
      func: -> @_sample_game_2 false
    }]
    @openMenuDialog
      self: @
      title: 'サンプルゲーム'
      menu: menu
    return

  _sample_game_2: (flag) ->
    menu = [{
      text: '1 vs 1'
      description: '1 対 1'
      func: -> @_generate_game
        player: flag
        team: [1,1]
        mapId: 0
    },{
      text: '3 vs 3'
      description: '3 対 3'
      func: -> @_generate_game
        player: flag
        team: [3,3]
        mapId: 0
    },{
      text: 'Return'
      description: '戻る'
      func: -> @_sample_game()
    }]
    @openMenuDialog
      self: @
      title: 'サンプルゲーム'
      menu: menu
    return

  ###* 新しいゲームを開始
  * @memberof nz.SceneTitleMenu#
  ###
  _debug_game: ->
    @exit 'battle',
      mapId: 1
      characters: [
        '001'
      ]
    return

  ###* 新しいゲームを開始
  * @memberof nz.SceneTitleMenu#
  ###
  _generate_game: (param)->
    {
      player
      team
      mapId
    } = {
      player: true
      mapId: 0
    }.$extend param

    ai = ['Shooter','Chaser','Runner']
    #ai = ['Runner']
    teamColors = nz.system.team.colors.clone().shuffle()

    i = 0
    characters = []
    for num,n in team
      teamName  = 'team ' + (n + 1)
      teamColor = teamColors.pop()
      for c in [0 ... num]
        i += 1
        name = 'キャラクター ' + i
        characters.push
          name:      name
          team:      teamName
          teamColor: teamColor
          ai:
            name:    ai.random()

    controlTeam = []
    controlTeam.push 'team 1' if player

    @app.replaceScene nz.SceneBattle
      mapId:       mapId
      controlTeam: controlTeam
      characters:  characters
      #endCondition:
      #  type: 'time'
      #  turn: 1
    return
