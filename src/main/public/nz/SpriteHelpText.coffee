###*
* @file SpriteHelpText.coffee
* ステータス表示用スプライト
###

SCREEN_W = nz.system.screen.width
SCREEN_H = nz.system.screen.height
CENTER_X = SCREEN_W / 2
CENTER_Y = SCREEN_H / 2

tm.define 'nz.SpriteHelpText',
  superClass: tm.display.TextShape

  init: (param = {}) ->
    {
      width
      height
      text
      fontSize
    } = param = {
      width: SCREEN_W
      height: 32
      fontSize: 14
    }.$extend param
    @superInit(param)
    @autoRender = false

    x = SCREEN_W
    y = SCREEN_H - @height / 2
    @setOrigin   0.0, 0.5
    @setPosition x,   y
    if text?
      @setText text

  setText: (text='') ->
    return if @_text is text
    @_text = text
    @fit()
    @render()
    if @_text isnt ''
      if @width > SCREEN_W
        # 長い場合にスクロールさせて表示
        x = SCREEN_W
        y = SCREEN_H - @height / 2
        @setOrigin 0.0,0.5
        @tweener
          .clear()
          .set(x:x,y:y)
          .move(-@width,y,@width * 50)
          .setLoop(true)
      else
        @setOrigin 0.5,0.5
        @setPosition CENTER_X, SCREEN_H - 16
    else
      @tweener.clear()
    return @

nz.SpriteHelpText.prototype.accessor 'text', {
  get: -> @_text
  set: (text) -> @setText(text)
}
