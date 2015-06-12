###*
* @file SceneBattleResult.coffee
* 戦闘結果の処理
###

SCREEN_W    = nz.system.screen.width
SCREEN_H    = nz.system.screen.height

tm.define 'nz.SceneBattleResult',
  superClass: nz.SceneBase

  init: (param) ->
    @superInit()
    {
      @mapSprite
      @data
    } = param

    @setOrigin(0.0,0.0)

    @width          = SCREEN_W - 32 * 2
    @height         = SCREEN_H - 32 * 2
    @bgColor        = 'gray'
    @boundingType   = 'rect'
    @interactive    = true
    @checkHierarchy = true

    @one 'enterframe', @setup

  setup: ->
    form =
      children:
        bg:
          type:          'RoundRectangleShape'
          x:             16
          y:             16
          width:         @width
          height:        @height
          strokeStyle:   'black'
          fillStyle:     @bgColor
          lineWidth:     1
          shadowBlur:    1
          shadowOffsetX: 2
          shadowOffsetY: 2
          shadowColor:   'gray'
          originX:       @originX
          originY:       @originY
        name:
          type:      'Label'
          text:      'Winner! ' + @data.winner.name
          fillStyle: 'black'
          align:     'left'
          baseline:  'top'
          x:         16 + 8
          y:         16 + 10
          originX:   @originX
          originY:   @originY
          fontSize:  8

    @fromJSON form

    @on 'enterframe' , @createKeyboradHander()
    @on 'pointingend', @_openBattleEndMenu
    @on 'input_enter', @_openBattleEndMenu

  _startReplay: ->
    @app.popScene()
    return

  _exitGame: ->
    @app.replaceScene nz.SceneTitleMenu()
    return

  _openBattleEndMenu: ->
    @openMenuDialog
      self: @
      title: 'Battle End'
      menu: [
        {name: 'Replay?',    func: @_startReplay}
        {name: 'Exit Game?', func: @_exitGame}
      ]
    return
