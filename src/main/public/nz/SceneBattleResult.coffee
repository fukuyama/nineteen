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
    } = param

    @setOrigin(0.0,0.0)

    @width          = SCREEN_W - 32 * 2
    @height         = SCREEN_H - 32 * 2
    @bgColor        = 'gray'
    @boundingType   = 'rect'
    @interactive    = true
    @checkHierarchy = true

    form =
      children:
        bg:
          type:          'RoundRectangleShape'
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

    @fromJSON form

    @on 'pointingend', (e) ->
      @one 'enterframe', -> @app.popScene()
      return
