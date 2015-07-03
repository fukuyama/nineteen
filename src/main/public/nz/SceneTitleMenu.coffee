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
        desctiption: '新しいゲームをはじめる'
        func: @_new_game
      }
      {
        name: 'Load Game'
        desctiption: '保存したゲームをはじめる'
        func: @_load_game
      }
      {
        name: 'Option'
        desctiption: 'ゲームオプション'
        func: @_option
      }
      {
        name: 'Debug Game'
        desctiption: 'デバックゲーム'
        func: @_debug_game
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
        new nz.Character(name:'キャラクター1',team:'teamA')
        new nz.Character(name:'キャラクター2',team:'teamA')
        new nz.Character(name:'キャラクター3',team:'teamA')
        new nz.Character(name:'キャラクター4',team:'teamB')
        new nz.Character(name:'キャラクター5',team:'teamB')
        new nz.Character(name:'キャラクター6',team:'teamB')
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
      controlTeam: []
      characters: [
        #new nz.Character(
        #  name:'キャラクター1'
        #  team:'teamA'
        #  spriteSheet:'character_test'
        #  weapon:
        #    damage: 20
        #)
        #new nz.Character(
        #  name:'キャラクター2'
        #  team:'teamA'
        #  spriteSheet:'character_test'
        #  ai:
        #    name: 'Shooter'
        #    src: 'nz/ai/Shooter.js'
        #)
        #new nz.Character(
        #  name:'キャラクター3'
        #  team:'teamA'
        #  spriteSheet:'character_test'
        #  ai:
        #    name: 'Default'
        #)
        new nz.Character(
          name:'キャラクター3'
          team:'teamA'
          spriteSheet:'character_test'
          ai:
            name: 'Runner'
            src: 'nz/ai/Runner.js'
        )
        #new nz.Character(
        #  name:'キャラクター4'
        #  team:'teamB'
        #  spriteSheet:'character_test'
        #  ai:
        #    name: 'Shooter'
        #    src: 'nz/ai/Shooter.js'
        #)
        #new nz.Character(
        #  name:'キャラクター5'
        #  team:'teamB'
        #  spriteSheet:'character_test'
        #  ai:
        #    name: 'Runner'
        #    src: 'nz/ai/Runner.js'
        #)
        new nz.Character(
          name:'キャラクター6'
          team:'teamB'
          spriteSheet:'character_test'
          ai:
            name: 'Shooter'
            src: 'nz/ai/Shooter.js'
        )
      ]
    )
    return
