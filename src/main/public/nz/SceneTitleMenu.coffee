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

    menu = [
      {
        name: 'New Game'
        description: '新しいゲームをはじめる'
        func: @_new_game
      }
      {
        name: 'Debug Game'
        description: 'デバッグゲームをはじめる'
        func: @_debug_game
      }
      {
        name: 'Load Game'
        description: '保存したゲームをはじめる'
        func: @_load_game
      }
      {
        name: 'Option'
        description: 'ゲームオプション'
        func: @_option
      }
    ]

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
  * @constructor nz.SceneTitleMenu#
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
  * @constructor nz.SceneTitleMenu#
  ###
  _load_game: ->
    console.log 'load game'
    return

  ###* システムオプション
  * @constructor nz.SceneTitleMenu#
  ###
  _option: ->
    console.log 'option'
    return

  ###* 新しいゲームを開始
  * @constructor nz.SceneTitleMenu#
  ###
  _debug_game: ->
    @app.replaceScene nz.SceneBattle(
      mapId: 0
      controlTeam: ['teamA']
      characters: [
        new nz.Character(
          name:'キャラクター1'
          team:'teamA'
          spriteSheet:'character_test'
          weapon:
            damage: 20
        )
        new nz.Character(
          name:'キャラクター2'
          team:'teamA'
          spriteSheet:'character_test'
          ai:
            name: 'Shooter'
            src: 'nz/ai/Shooter.js'
        )
        {
          name:'キャラクター3'
          team:'teamA'
          spriteSheet:'character_test'
          ai:
            name: 'Runner'
            src: 'nz/ai/Runner.js'
        }
        new nz.Character(
          name:'キャラクター4'
          team:'teamB'
          teamColor: [0,0,0]
          spriteSheet:'character_test'
          ai:
            name: 'Shooter'
            src: 'nz/ai/Shooter.js'
        )
        new nz.Character(
          name:'キャラクター5'
          team:'teamB'
          teamColor: [0,0,0]
          spriteSheet:'character_test'
          ai:
            name: 'Runner'
            src: 'nz/ai/Runner.js'
        )
        {
          name:'キャラクター6'
          team:'teamB'
          teamColor: [0,0,0]
          spriteSheet:'character_test'
          ai:
            name: 'Shooter'
            src: 'nz/ai/Shooter.js'
        }
      ]
    )
    return
