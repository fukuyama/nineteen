###*
* @file SceneBattleShotCommand.coffee
* 射撃コマンドシーン
###

tm.define 'nz.SceneBattleShotCommand',
  superClass: nz.SceneBase

  init: (param) ->
    @superInit()
    {
      @turn
      @target
      @callback
      @mapSprite
    } = param

    @costa = @target.character.getActionCost(@turn)

    @_keyInput = false
    @_keyRotate = 0
    @on 'enterframe'  , @createKeyboradHander()
    @on 'input_left'  , @_inputLeft
    @on 'repeat_left' , @_inputLeft
    @on 'input_right' , @_inputRight
    @on 'repeat_right', @_inputRight
    #@on 'input_enter'  , @inputEnter

    @on 'map.pointingstart', -> @_keyInput = false
    @on 'map.pointingend',   @_pointEnd
    @_createPointer()

  _inputLeft: ->
    @_keyInput = true
    @_keyRotate -= 5
    @_rotatePointer @_keyRotate
    return

  _inputRight: ->
    @_keyInput = true
    @_keyRotate += 5
    @_rotatePointer @_keyRotate
    return

  _rotatePointer: (r) ->
    if @pointer?
      tcsr = @target.character.shot.range

      r = nz.utils.relativeRotation(@target.body.rotation,r)
      @target.checkDirection(
        r:             r
        start:         tcsr.start
        end:           tcsr.end
        anticlockwise: tcsr.anticlockwise
        callback: ((result,ra) ->
          ra += @target.body.rotation
          unless result
            @_keyRotate = ra
          @pointer.rotation = ra
        ).bind @
      )
    return

  update: (app) ->
    @_movePointer(app.pointing) unless @_keyInput
    return

  _pointStart: (e) ->
    #@_removePointer()
    #@_createPointer()
    @_movePointer(e.pointing)
    return

  _pointMove: (e) ->
    @_movePointer(e.pointing)
    return

  _pointEnd: (e) ->
    @_setupCommand()
    @_removePointer()
    @_endScene()
    return

  _setupCommand: ->
    if @pointer?
      @callback(@pointer.rotation)
    return

  _endScene: ->
    @one 'enterframe', -> @app.popScene()
    return

  _createPointer: ->
    @pointer = tm.display.Shape(
      width: 10
      height: 10
    ).addChildTo @mapSprite
      .setPosition @target.x,@target.y
    tm.display.CircleShape(
      x: 40
      width: 10
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

  _movePointer: (pointing) ->
    if @pointer?
      t    = @mapSprite.globalToLocal pointing
      tcsr = @target.character.shot.range

      @target.checkDirection(
        x:             t.x
        y:             t.y
        start:         tcsr.start
        end:           tcsr.end
        anticlockwise: tcsr.anticlockwise
        callback: ((result,r) ->
          if result
            x = t.x - @target.x
            y = t.y - @target.y
            v = tm.geom.Vector2 x,y
            r = Math.radToDeg v.toAngle()
          else
            r += @target.body.rotation
          @pointer.rotation = r
        ).bind @
      )
    return
