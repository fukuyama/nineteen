###*
* @file SceneBattleRotatePointer.coffee
* 方向指示用のポインターを操作するシーンクラス
###

phina.define 'nz.SceneBattleRotatePointer',

  superClass: nz.SceneBase

  init: (param) ->
    @superInit()
    {
      @turn
      @target
      @callback
      @mapSprite
    } = param

    @_keyInput = true
    @_keyRotate = @target.body.rotation
    @_keyRotateMult = 5

    @setupKeyboradHander()

    @on 'input_left'  , @_inputLeft
    @on 'repeat_left' , @_inputLeft
    @on 'input_right' , @_inputRight
    @on 'repeat_right', @_inputRight
    @on 'input_enter' , @_pointEnd
    @on 'input_escape', @_endScene

    @on 'map.pointingover', -> @_keyInput = false
    @on 'map.pointingend', @_pointEnd
    @_createPointer()
    return

  _inputLeft: ->
    @_keyInput = true
    @_keyRotate -= @_keyRotateMult
    @_rotatePointer @_keyRotate
    return

  _inputRight: ->
    @_keyInput = true
    @_keyRotate += @_keyRotateMult
    @_rotatePointer @_keyRotate
    return

  update: (app) ->
    @_movePointer(app.pointing) unless @_keyInput
    return

  _pointEnd: (e) ->
    @_setupCommand()
    @_endScene()
    return

  _setupCommand: ->
    return

  _rotatePointer: (r) ->
    return

  _movePointer: (pointing) ->
    return

  _endScene: ->
    @_removePointer()
    @one 'enterframe', -> @app.popScene()
    return

  _createPointer: ->
    @pointer = tm.display.Shape(
      width:  10
      height: 10
    ).addChildTo @mapSprite
      .setPosition @target.x,@target.y
    tm.display.CircleShape(
      x:      40
      width:  10
      height: 10
      fillStyle: 'blue'
    ).addChildTo @pointer
    @pointer.rotation = @target.body.rotation
    return

  _removePointer: ->
    if @pointer?
      @pointer.remove()
      @pointer = null
    return
