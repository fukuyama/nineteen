###*
* @file Character.coffee
* キャラクター情報
###

tm.define 'nz.Character',

  ###* 初期化
  * @classdesc キャラクタークラス
  * @constructor nz.Character
  ###
  init: (param = {}) ->
    @.$extend {
      name: 'テストキャラクター'
      spriteSheet: 'character_001'
      mapx: 0
      mapy: 0
      direction: 1
      weapon:
        height: 48
        width: 8
        rotation:
          start: 0
          end: 120
        speed: 300
    }.$extend param
    return
