###*
* @file SceneTitleMenu.coffee
* タイトルシーン
###

tm.define 'nz.SceneTitleMenu',
  superClass: nz.SceneBase

  ###* 初期化
  * @classdesc タイトルシーンクラス
  * @constructor nz.SceneTitleMenu
  ###
  init: () ->
    @superInit()

    @on 'enter', ->
      scene = tm.game.TitleScene(title:nz.system.title)
      scene.on 'enterframe', ->
        if @app.keyboard.getKeyDown('enter')
          @onpointingstart()
      @app.pushScene scene

    @on 'resume', ->
      @_sample_game()
      return

    return

  _main_menu: ->
    menu = [{
    #  name: 'New Game'
    #  description: '新しいゲームをはじめる'
    #  func: @_new_game
    #},{
    #  name: 'Sample Game'
    #  description: 'サンプルゲームをはじめる'
    #  func: @_sample_game
    #},{
      name: 'Debug Game'
      description: 'デバッグゲームをはじめる'
      func: @_debug_game
    },{
      name: 'Load Game'
      description: '保存したゲームをはじめる'
      func: @_load_game
    },{
      name: 'Option'
      description: 'ゲームオプション'
      func: @_option
    }]
    @openMenuDialog
      self: @
      title: nz.system.title
      menu: menu

  ###* 新しいゲームを開始
  * @memberof nz.SceneTitleMenu#
  ###
  _new_game: ->
    @app.replaceScene nz.SceneBattle(
      mapId: 1
      controlTeam: ['teamA']
      characters: [
        {name:'キャラクター1',team:'teamA'}
        {name:'キャラクター2',team:'teamA'}
        {name:'キャラクター3',team:'teamA'}
        {name:'キャラクター4',team:'teamB'}
        {name:'キャラクター5',team:'teamB'}
        {name:'キャラクター6',team:'teamB'}
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
      name: 'Player vs Computer'
      description: 'プレイヤー 対 コンピューター'
      func: -> @_sample_game_2 true
    },{
      name: 'Computer vs Computer'
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
      name: '1 vs 1'
      description: '1 対 1'
      func: -> @_generate_game
        player: flag
        team: [1,1]
        mapId: 0
    },{
      name: '3 vs 3'
      description: '3 対 3'
      func: -> @_generate_game
        player: flag
        team: [3,3]
        mapId: 0
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
    @app.replaceScene nz.SceneBattle(
      mapId: 1
      controlTeam: []
      characters: [
        {
          name:'キャラクター1'
          team:'teamA'
          ai:
            name: 'Chaser'
          weapon:
            damage: 40
            height: 48
            width: 12
            range:
              start: 0
              end: 120
            speed: 600
        }
        #{
        #  name:'キャラクター2'
        #  team:'teamA'
        #  ai:
        #    name: 'Shooter'
        #}
        #{
        #  name:'キャラクター3'
        #  team:'teamA'
        #  ai:
        #    name: 'Runner'
        #}
        {
          name:'キャラクター4'
          team:'teamB'
          teamColor: [0,0,0]
          ai:
            name: 'Shooter'
        }
        #{
        #  name:'キャラクター5'
        #  team:'teamB'
        #  teamColor: [0,0,0]
        #  ai:
        #    name: 'Runner'
        #}
        #{
        #  name:'キャラクター6'
        #  team:'teamB'
        #  teamColor: [0,0,0]
        #  ai:
        #    name: 'Shooter'
        #}
      ]
    )
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
