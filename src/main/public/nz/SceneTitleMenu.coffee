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

    @on 'enter', ->
      scene = tm.game.TitleScene(title:nz.system.title)
      scene.on 'enterframe', ->
        if @app.keyboard.getKeyDown('enter')
          @onpointingstart()
      @app.pushScene scene

    @on 'resume', ->
      @openMenuDialog
        self: @
        title: nz.system.title
        menu: menu

    return

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
    @openMenuDialog
      self: @
      title: 'サンプルゲーム'
      menu: [{
        name: 'Player vs COM'
        func: ->
          return
      },{
        name: 'COM vs COM'
      }]
    return

  ###* 新しいゲームを開始
  * @memberof nz.SceneTitleMenu#
  ###
  _debug_game: ->
    @app.replaceScene nz.SceneBattle(
      mapId: 0
      controlTeam: []
      characters: [
        {
          name:'キャラクター1'
          team:'teamA'
          ai:
            name: 'Chaser'
          weapon:
            damage: 4
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
