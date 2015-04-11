/*
 * 19 0.0.1
 * 
 * MIT Licensed
 *
 * Copyright (C) 2015 Yoshihito Fukuyama (https://ja.gravatar.com/yf37)
 */

/**
* @file System.coffee
* システム情報
 */

(function() {
  tm.define('nz.System', {

    /** 初期化
    * @classdesc システムクラス
    * @constructor nz.System
     */
    init: function() {
      this.$extend({
        title: 'Nineteen',
        DIRECTION_NUM: {
          UP: 0,
          UP_RIGHT: 1,
          DOWN_RIGHT: 2,
          DOWN: 3,
          DOWN_LEFT: 4,
          UP_LEFT: 5
        },
        character: {
          directions: [
            {
              name: 'up',
              rotation: -90,
              index: 0,
              rotateIndex: [0, 1, 2, 3, -2, -1]
            }, {
              name: 'up_right',
              rotation: -30,
              index: 1,
              rotateIndex: [-1, 0, 1, 2, 3, -2]
            }, {
              name: 'down_right',
              rotation: 30,
              index: 2,
              rotateIndex: [-2, -1, 0, 1, 2, 3]
            }, {
              name: 'down',
              rotation: 90,
              index: 3,
              rotateIndex: [3, -2, -1, 0, 1, 2]
            }, {
              name: 'down_left',
              rotation: 150,
              index: 4,
              rotateIndex: [2, 3, -2, -1, 0, 1]
            }, {
              name: 'up_left',
              rotation: -150,
              index: 5,
              rotateIndex: [1, 2, 3, -2, -1, 0]
            }, {
              name: 'default',
              rotation: 90,
              index: 6,
              rotateIndex: [0, 1, 2, 3, -2, -1]
            }
          ],
          action_cost: {
            rotate: 1,
            attack: 2,
            shot: 2
          }
        },
        map: {
          chip: {
            width: 32,
            height: 32
          }
        },
        screen: {
          width: 640,
          height: 480
        },
        dialog: {
          strokeStyle: 'rgba(255,255,255,1.0)',
          fillStyle: 'rgba(128,128,128,1.0)'
        },
        assets: {
          chipdata: 'data/chipdata.json',
          map_object: 'img/map_object.png',
          map_chip: 'img/map_chip.png',
          character_001: {
            type: 'tmss',
            src: 'data/character_001.json'
          }
        },
        MESSAGES: {
          battle: {
            position: {
              setiing: '{name} の開始位置を選択してください。'
            }
          }
        }
      });
      this.ai = {};
    },
    addAI: function(name, ai) {
      return this.ai[name] = ai;
    }
  });

  nz.system = nz.System();

}).call(this);


/**
* @file Graph.coffee
* A*用グラフクラス
 */

(function() {
  var _g, nz, ref;

  _g = typeof window !== "undefined" && window !== null ? window : global;

  nz = _g.nz = (ref = _g.nz) != null ? ref : {};

  _g = void 0;

  nz.Graph = (function() {
    function Graph(param) {
      var chipdata, chipid, i, j, k, mapdata, node, ref1, ref2, ref3, x, y;
      if (param == null) {
        param = {};
      }
      mapdata = param.mapdata, chipdata = param.chipdata;
      this.nodes = [];
      this.grid = [];
      for (x = i = 0, ref1 = mapdata.width; 0 <= ref1 ? i < ref1 : i > ref1; x = 0 <= ref1 ? ++i : --i) {
        this.grid[x] = [];
      }
      for (y = j = 0, ref2 = mapdata.height; 0 <= ref2 ? j < ref2 : j > ref2; y = 0 <= ref2 ? ++j : --j) {
        for (x = k = 0, ref3 = mapdata.width; 0 <= ref3 ? k < ref3 : k > ref3; x = 0 <= ref3 ? ++k : --k) {
          if (!(y === mapdata.height - 1 && x % 2 === 0)) {
            chipid = mapdata.data[y][x];
            node = new nz.GridNode(x, y, chipdata[chipid]);
            this.grid[x][y] = node;
            this.nodes.push(node);
          }
        }
      }
      this.clear();
    }

    Graph.prototype.clear = function() {
      var i, len, node, ref1, results;
      ref1 = this.nodes;
      results = [];
      for (i = 0, len = ref1.length; i < len; i++) {
        node = ref1[i];
        node.clean();
        results.push(astar.cleanNode(node));
      }
      return results;
    };

    Graph.prototype.cleanDirty = function() {};

    Graph.prototype.markDirty = function(node) {};

    Graph.prototype.neighbors = function(node) {
      var ref1, ref10, ref11, ref12, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ref9, ret, x, y;
      ret = [];
      x = node.x;
      y = node.y;
      if (x % 2 === 0) {
        if ((((ref1 = this.grid[x]) != null ? ref1[y - 1] : void 0) != null)) {
          ret.push(this.grid[x][y - 1]);
        }
        if ((((ref2 = this.grid[x]) != null ? ref2[y + 1] : void 0) != null)) {
          ret.push(this.grid[x][y + 1]);
        }
        if ((((ref3 = this.grid[x - 1]) != null ? ref3[y] : void 0) != null)) {
          ret.push(this.grid[x - 1][y]);
        }
        if ((((ref4 = this.grid[x - 1]) != null ? ref4[y + 1] : void 0) != null)) {
          ret.push(this.grid[x - 1][y + 1]);
        }
        if ((((ref5 = this.grid[x + 1]) != null ? ref5[y] : void 0) != null)) {
          ret.push(this.grid[x + 1][y]);
        }
        if ((((ref6 = this.grid[x + 1]) != null ? ref6[y + 1] : void 0) != null)) {
          ret.push(this.grid[x + 1][y + 1]);
        }
      } else {
        if ((((ref7 = this.grid[x]) != null ? ref7[y - 1] : void 0) != null)) {
          ret.push(this.grid[x][y - 1]);
        }
        if ((((ref8 = this.grid[x]) != null ? ref8[y + 1] : void 0) != null)) {
          ret.push(this.grid[x][y + 1]);
        }
        if ((((ref9 = this.grid[x - 1]) != null ? ref9[y] : void 0) != null)) {
          ret.push(this.grid[x - 1][y]);
        }
        if ((((ref10 = this.grid[x - 1]) != null ? ref10[y - 1] : void 0) != null)) {
          ret.push(this.grid[x - 1][y - 1]);
        }
        if ((((ref11 = this.grid[x + 1]) != null ? ref11[y] : void 0) != null)) {
          ret.push(this.grid[x + 1][y]);
        }
        if ((((ref12 = this.grid[x + 1]) != null ? ref12[y - 1] : void 0) != null)) {
          ret.push(this.grid[x + 1][y - 1]);
        }
      }
      return ret;
    };

    Graph.prototype.toString = function() {
      var graphString, i, j, len, len1, node, nodes, ref1, rowDebug;
      graphString = [];
      ref1 = this.grid;
      for (i = 0, len = ref1.length; i < len; i++) {
        nodes = ref1[i];
        rowDebug = [];
        for (j = 0, len1 = nodes.length; j < len1; j++) {
          node = nodes[j];
          rowDebug.push(node.weight);
        }
        graphString.push(rowDebug.join(" "));
      }
      return graphString.join("\n");
    };

    Graph.prototype.searchRoute = function(sd, sx, sy, ex, ey) {
      var end, i, len, node, result, route, start;
      route = [];
      start = this.grid[sx][sy];
      end = this.grid[ex][ey];
      start.direction = sd;
      result = astar.search(this, start, end, {
        heuristic: nz.Graph.heuristic
      });
      for (i = 0, len = result.length; i < len; i++) {
        node = result[i];
        route.push({
          mapx: node.x,
          mapy: node.y,
          direction: node.direction,
          cost: node.g
        });
      }
      this.clear();
      return route;
    };

    return Graph;

  })();

  nz.Graph.heuristic = function(node1, node2) {
    var direction, hd, hr, hx, hy;
    hx = Math.abs(node1.x - node2.x);
    hy = Math.abs(node1.y - node2.y);
    hr = Math.ceil(hx / 2);
    direction = node1.calcDirectionTo(node2);
    hd = node1.getDirectionCost(direction);
    if (hy === hr) {
      hy = 0;
    } else if (hy < hr) {
      if (hy !== 0) {
        hy = 1;
        if (hd === 1) {
          hd = 0;
        }
      }
    } else {
      hy -= hr;
    }
    return hx + hy + hd;
  };

}).call(this);


/**
* @file GridNode.coffee
* A*用ノードクラス
 */

(function() {
  var _g, nz, ref;

  _g = typeof window !== "undefined" && window !== null ? window : global;

  nz = _g.nz = (ref = _g.nz) != null ? ref : {};

  _g = void 0;

  nz.GridNode = (function() {

    /**
    * @param {Object} chipdata
    * @param {number} chipdata.weight
    * @param {number} chipdata.frame
    * @param {string} chipdata.name
     */
    function GridNode(x, y, chipdata) {
      if (chipdata == null) {
        chipdata = {
          weight: 0
        };
      }
      this.x = x;
      this.y = y;
      this.weight = chipdata.weight, this.frame = chipdata.frame, this.name = chipdata.name, this.object = chipdata.object;
      this.clean();
    }

    GridNode.prototype.clean = function() {
      this.direction = 0;
    };

    GridNode.prototype.toString = function() {
      return "[" + this.x + "," + this.y + "]";
    };


    /**
    * 指定されたノードが、自分から見てどの方向にあるか
    * @param node {GridNode} 調査対象ノード
     */

    GridNode.prototype.calcDirection = function(node) {
      return nz.GridNode.calcDirection(this, node);
    };

    GridNode.prototype.calcDirectionTo = function(node) {
      return this.calcDirection(node);
    };

    GridNode.prototype.calcDirectionBy = function(node) {
      return node.calcDirection(this);
    };


    /**
    * 曲がる場合のコスト
    * @param direction {number} 方向(1-6)
     */

    GridNode.prototype.getDirectionCost = function(direction) {
      return nz.GridNode.calcDirectionCost(this.direction, direction);
    };


    /**
    * 自分のノードに、指定されたノードから移動する（入る）場合のコスト
    * @param node {GridNode} 移動元ノード
     */

    GridNode.prototype.getCost = function(node) {
      var cost, direction;
      cost = this.weight;
      direction = node.calcDirection(this);
      cost += node.getDirectionCost(direction);
      if (!this.visited || node.g + cost < this.g) {
        this.direction = direction;
      }
      return cost;
    };


    /**
    * 壁判定
     */

    GridNode.prototype.isWall = function() {
      return this.weight === 0;
    };

    return GridNode;

  })();

  nz.GridNode.calcDirection = function(node1, node2) {
    var direction;
    direction = 0;
    if (node1.x === node2.x) {
      if (node1.y > node2.y) {
        direction = 0;
      }
      if (node1.y < node2.y) {
        direction = 3;
      }
    } else if (node1.x > node2.x) {
      if (node1.y === node2.y) {
        direction = node1.x % 2 === 0 ? 5 : 4;
      } else if (node1.y > node2.y) {
        direction = 5;
      } else if (node1.y < node2.y) {
        direction = 4;
      }
    } else if (node1.x < node2.x) {
      if (node1.y === node2.y) {
        direction = node1.x % 2 === 0 ? 1 : 2;
      } else if (node1.y > node2.y) {
        direction = 1;
      } else if (node1.y < node2.y) {
        direction = 2;
      }
    }
    return direction;
  };

  nz.GridNode.calcDirectionCost = function(direction1, direction2) {
    return Math.abs(3 - Math.abs((direction2 - direction1 - 3) % 6));
  };

}).call(this);


/**
* @file Character.coffee
* キャラクター情報
 */

(function() {
  var ACTION_COST, DIRECTIONS;

  DIRECTIONS = nz.system.character.directions;

  ACTION_COST = nz.system.character.action_cost;

  tm.define('nz.Character', {

    /** 初期化
    * @classdesc キャラクタークラス
    * @constructor nz.Character
     */
    init: function(param) {
      if (param == null) {
        param = {};
      }
      this.$extend({
        name: 'テストキャラクター',
        spriteSheet: 'character_001',
        team: 'teamA',
        ai: {
          name: 'SampleAI',
          src: 'nz/ai/SampleAI.js'
        },
        hp: 10,
        sp: 10,
        ap: 6,
        mapx: -1,
        mapy: -1,
        direction: 0,
        move: {
          speed: 300
        },
        weapon: {
          height: 48,
          width: 12,
          rotation: {
            start: 0,
            end: 120,
            anticlockwise: false
          },
          speed: 600
        },
        shot: {
          rotation: {
            start: 0,
            end: -120,
            anticlockwise: true
          },
          distance: 32 * 8,
          speed: 100
        },
        commands: []
      }.$extend(param));
    },
    _command: function(i) {
      if (i == null) {
        i = this.commands.length - 1;
      }
      if (this.commands[i] == null) {
        this.commands[i] = {};
        this.clearAction(i);
      }
      return this.commands[i];
    },
    createAiInfo: function(i) {
      var info;
      info = {
        name: this.name,
        hp: this.hp,
        sp: this.sp,
        ap: this.ap,
        mapx: this.mapx,
        mapy: this.mapy,
        direction: this.direction,
        team: this.team,
        move: JSON.parse(JSON.stringify(this.move)),
        weapon: JSON.parse(JSON.stringify(this.weapon)),
        shot: JSON.parse(JSON.stringify(this.shot))
      };
      return nz.Character(info);
    },

    /** アクション削除
    * @param {number} i 戦闘ターン数
     */
    clearAction: function(i) {
      var command;
      command = this._command(i);
      command.attack = false;
      command.actions = [];
      command.cost = 0;
    },
    clearMoveAction: function(i) {
      var command;
      command = this._command(i);
      command.actions = [];
      command.cost = 0;
      if (this.isAttackAction(i)) {
        command.cost += ACTION_COST.attack;
      }
    },
    clearShotAction: function(i) {
      var action, actions, command, j, len, ref;
      command = this._command(i);
      actions = [];
      ref = command.actions;
      for (j = 0, len = ref.length; j < len; j++) {
        action = ref[j];
        if (action.shot != null) {
          command.cost += ACTION_COST.shot;
        }
        actions.push(action);
      }
      command.actions = actions;
    },

    /** アクションコストの取得
    * @param {number} i 戦闘ターン数
     */
    getActionCost: function(i) {
      return this._command(i).cost;
    },

    /** 残りのアクションポイント
    * @param {number} i 戦闘ターン数
     */
    getRemnantAp: function(i) {
      return this.ap - this.getActionCost(i);
    },

    /** 移動ルートの追加
    * @param {number} i 戦闘ターン数
    * @param {Array} route 移動ルート
     */
    addMoveCommand: function(i, route) {
      var a, command, cost, direction, j, k, len, len1, prev, r, ref;
      command = this._command(i);
      direction = this.direction;
      ref = command.actions;
      for (j = 0, len = ref.length; j < len; j++) {
        a = ref[j];
        if (a.rotate != null) {
          direction = a.rotate.direction;
        }
      }
      prev = command.cost;
      cost = 0;
      for (k = 0, len1 = route.length; k < len1; k++) {
        r = route[k];
        if (direction !== r.direction) {
          this.addRotateCommand(i, direction, DIRECTIONS[direction].rotateIndex[r.direction]);
          direction = r.direction;
        }
        r.speed = this.move.speed;
        command.actions.push({
          move: r
        });
        cost = r.cost;
      }
      command.cost = prev + cost;
      return this;
    },

    /** 方向転換の追加
    * @param {number} i 戦闘ターン数
    * @param {number} direction1 元の向き
    * @param {number} rotateIndex 方向転換する量(マイナスは反時計回り)
     */
    addRotateCommand: function(i, direction1, rotateIndex) {
      var command, j, ref;
      command = this._command(i);
      for (i = j = 0, ref = rotateIndex; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        if (!(i !== 0)) {
          continue;
        }
        command.actions.push({
          rotate: {
            direction: (direction1 + i + 6) % 6,
            speed: this.move.speed
          }
        });
        command.cost += ACTION_COST.rotate;
      }
      return this;
    },

    /** 攻撃モードの設定
    * @param {number}  i    戦闘ターン数
    * @param {boolean} flag 攻撃する場合 true
     */
    setAttackCommand: function(i, flag) {
      var command;
      if (flag == null) {
        flag = true;
      }
      if (this.ap >= ACTION_COST.attack) {
        command = this._command(i);
        if (command.attack !== flag) {
          if (flag) {
            command.cost += ACTION_COST.attack;
          } else {
            command.cost -= ACTION_COST.attack;
          }
          command.attack = flag;
        }
      }
      return this;
    },

    /** 射撃角度の追加
    * @param {number} i        戦闘ターン数
    * @param {number} rotation 射撃角度
     */
    addShotCommand: function(i, rotation) {
      var command;
      command = this._command(i);
      command.actions.push({
        shot: {
          rotation: rotation,
          distance: this.shot.distance,
          speed: this.shot.speed
        }
      });
      command.cost += ACTION_COST.shot;
      return this;
    },

    /** 射撃アクションを行っているかどうか
    * @param {number} i 戦闘ターン数
    * @return {boolean} 射撃アクションを設定していたら true
     */
    isShotAction: function(i) {
      var action, command, j, len, ref;
      command = this._command(i);
      ref = command.actions;
      for (j = 0, len = ref.length; j < len; j++) {
        action = ref[j];
        if (action.shot != null) {
          return true;
        }
      }
      return false;
    },

    /** 攻撃アクションを行っているかどうか
    * @param {number} i 戦闘ターン数
    * @return {boolean} 攻撃アクションを設定していたら true
     */
    isAttackAction: function(i) {
      var command;
      command = this._command(i);
      return command.attack;
    },

    /** 移動アクションを行っているかどうか
    * @param {number} i 戦闘ターン数
    * @return {boolean} 移動アクションを設定していたら true
     */
    isMoveAction: function(i) {
      var action, command, j, len, ref;
      command = this._command(i);
      ref = command.actions;
      for (j = 0, len = ref.length; j < len; j++) {
        action = ref[j];
        if (action.move != null) {
          return true;
        }
      }
      return false;
    }
  });

}).call(this);


/**
* @file SpriteBattleMap.coffee
* 戦闘マップスプライト
 */

(function() {
  var MAP_CHIP_H, MAP_CHIP_W;

  MAP_CHIP_W = nz.system.map.chip.width;

  MAP_CHIP_H = nz.system.map.chip.height;

  tm.define('nz.SpriteBattleMap', {
    superClass: tm.display.CanvasElement,

    /** 初期化
    * @classdesc 戦闘マップスプライト
    * @constructor nz.SpriteBattleMap
     */
    init: function(mapName) {
      var chip, h, i, j, k, l, len, len1, line, mapx, mapy, ref, ref1, ref2, self;
      this.superInit();
      this._chips = [];
      this._blinks = [];
      this._activeBlinks = [];
      this.characterSprites = [];
      this.map = tm.asset.Manager.get(mapName).data;
      this.graph = new nz.Graph({
        mapdata: this.map,
        chipdata: tm.asset.Manager.get('chipdata').data
      });
      this.width = this.map.width * MAP_CHIP_W;
      this.height = this.map.height * MAP_CHIP_H;
      for (mapx = i = 0, ref = this.map.width; 0 <= ref ? i < ref : i > ref; mapx = 0 <= ref ? ++i : --i) {
        h = mapx % 2 !== 0 ? this.map.height : this.map.width - 1;
        for (mapy = j = 0, ref1 = h; 0 <= ref1 ? j < ref1 : j > ref1; mapy = 0 <= ref1 ? ++j : --j) {
          this._initMapChip(mapx, mapy);
        }
      }
      this.cursor = this._createCursor().addChildTo(this);
      self = this;
      ref2 = this._chips;
      for (k = 0, len = ref2.length; k < len; k++) {
        line = ref2[k];
        for (l = 0, len1 = line.length; l < len1; l++) {
          chip = line[l];
          chip.on('pointingover', function() {
            self.cursor.x = this.x;
            return self.cursor.y = this.y;
          });
        }
      }
      this.on('battleSceneStart', function(e) {
        this.cursor.visible = false;
      });
      this.on('battleSceneEnd', function(e) {
        return this.cursor.visible = true;
      });
    },
    findCharacter: function(mapx, mapy) {
      var character, i, len, ref, res;
      res = [];
      ref = this.characterSprites;
      for (i = 0, len = ref.length; i < len; i++) {
        character = ref[i];
        if (character.mapx === mapx && character.mapy === mapy) {
          res.push(character);
        }
      }
      return res;
    },
    findCharacterGhost: function(mapx, mapy) {
      var character, i, len, ref, ref1, ref2, res;
      res = [];
      ref = this.characterSprites;
      for (i = 0, len = ref.length; i < len; i++) {
        character = ref[i];
        if (((ref1 = character.ghost) != null ? ref1.mapx : void 0) === mapx && ((ref2 = character.ghost) != null ? ref2.mapy : void 0) === mapy) {
          res.push(character.ghost);
        }
      }
      return res;
    },
    _createCursor: function() {
      var cursor;
      cursor = tm.display.Shape({
        width: MAP_CHIP_W,
        height: MAP_CHIP_H,
        strokeStyle: 'red',
        lineWidth: 3,
        visible: false
      });
      cursor._render = function() {
        return this.canvas.strokeRect(0, 0, this.width, this.height);
      };
      cursor.render();
      return cursor;
    },
    _dispatchMapChipEvent: function(_e) {
      var e;
      e = tm.event.Event('map.' + _e.type);
      e.app = _e.app;
      e.pointing = _e.pointing;
      e.mapx = this.mapx;
      e.mapy = this.mapy;
      e.app.currentScene.dispatchEvent(e);
    },
    _initMapChip: function(mapx, mapy) {
      var blink, chip, frameIndex, h, node, w, x, y;
      w = MAP_CHIP_W;
      h = MAP_CHIP_H;
      x = mapx * w + w * 0.5;
      y = mapy * h + h * 0.5;
      if (mapx % 2 === 0) {
        y += h * 0.5;
      }
      node = this.graph.grid[mapx][mapy];
      frameIndex = node.frame;
      chip = tm.display.Sprite('map_chip', w, h).addChildTo(this).setPosition(x, y).setFrameIndex(frameIndex).setInteractive(true).setBoundingType('rect').on('pointingstart', this._dispatchMapChipEvent).on('pointingover', this._dispatchMapChipEvent).on('pointingout', this._dispatchMapChipEvent).on('pointingend', this._dispatchMapChipEvent);
      chip.mapx = mapx;
      chip.mapy = mapy;
      if (node.object != null) {
        tm.display.Sprite('map_object', w, h * 2).setOrigin(0.5, 0.75).addChildTo(chip).setFrameIndex(node.object.frame);
      }
      blink = tm.display.RectangleShape({
        width: w,
        height: h,
        strokeStyle: 'white',
        fillStyle: 'white'
      }).addChildTo(this).setPosition(x, y).setInteractive(true).setAlpha(0.0).setVisible(false);
      if (this._chips[mapx] == null) {
        this._chips[mapx] = [];
      }
      this._chips[mapx][mapy] = chip;
      if (this._blinks[mapx] == null) {
        this._blinks[mapx] = [];
      }
      this._blinks[mapx][mapy] = blink;
    },
    blink: function(mapx, mapy) {
      var blink, ref;
      blink = (ref = this._blinks[mapx]) != null ? ref[mapy] : void 0;
      if (blink != null) {
        blink.visible = true;
        blink.tweener.clear().fade(0.5, 300).fade(0.1, 300).setLoop(true);
        this._activeBlinks.push(blink);
      }
    },
    clearBlink: function() {
      var blink, i, len, ref;
      ref = this._activeBlinks;
      for (i = 0, len = ref.length; i < len; i++) {
        blink = ref[i];
        blink.visible = false;
        blink.setAlpha(0.0);
        blink.tweener.clear();
      }
      this._activeBlinks.clear();
    },
    isBlink: function(mapx, mapy) {
      return this._blinks[mapx][mapy].visible;
    },
    getMapChip: function(mapx, mapy) {
      return this._chips[mapx][mapy];
    }
  });

}).call(this);


/**
* @file SpriteCharacter.coffee
* キャラクタースプライト
 */

(function() {
  var DIRECTIONS, MAP_CHIP_H, MAP_CHIP_W;

  MAP_CHIP_W = nz.system.map.chip.width;

  MAP_CHIP_H = nz.system.map.chip.height;

  DIRECTIONS = nz.system.character.directions;

  tm.define('nz.SpriteCharacter', {
    superClass: tm.display.AnimationSprite,

    /** 初期化
    * @classdesc キャラクタースプライトクラス
    * @constructor nz.SpriteCharacter
    * @param {nz.Character} character
     */
    init: function(index, character) {
      this.index = index;
      this.character = character;
      this.superInit(this.character.spriteSheet);
      this.checkHierarchy = true;
      this.ghost = null;
      this.body = tm.display.Shape({
        width: this.width,
        height: this.height
      }).addChildTo(this);
      this.weapon = tm.display.RectangleShape({
        width: this.character.weapon.height,
        height: this.character.weapon.width,
        strokeStyle: 'black',
        fillStyle: 'red'
      }).addChildTo(this.body).setOrigin(0.0, 0.5).setVisible(false);
      this.weapon.checkHierarchy = true;
      this.weapon.on('enterframe', this._enterframeWeapon.bind(this));
      this.setMapPosition(this.character.mapx, this.character.mapy);
      this.setDirection(this.character.direction);
      this.on('battleSceneStart', function() {
        this.clearGhost();
      });
      this.on('battleSceneEnd', function() {});
      this.on('battleTurnStart', function(e) {
        this.startAction(e.turn);
        this._weaponHitFlag = [];
      });
      this.on('battleTurnEnd', function(e) {
        this.update = null;
        this.attack = false;
      });
      this.on('hitWeapon', function(e) {
        this._hitWeapon(e.owner);
      });
      this.on('hitBallet', function(e) {
        this._hitBallet(e.owner, e.ballet);
      });
    },
    isGhost: function() {
      return this.alpha === 0.5;
    },
    hasGhost: function() {
      return this.ghost !== null;
    },
    createGhost: function(direction, mapx, mapy) {
      this.clearGhost();
      this.ghost = nz.SpriteCharacter(this.index, this.character).setAlpha(0.5).setMapPosition(mapx, mapy).setDirection(direction);
      return this.ghost;
    },
    clearGhost: function() {
      if (this.ghost != null) {
        this.ghost.remove();
        this.ghost = null;
      }
    },
    setMapPosition: function(mapx1, mapy1) {
      var h, w;
      this.mapx = mapx1;
      this.mapy = mapy1;
      w = MAP_CHIP_W;
      h = MAP_CHIP_H;
      this.x = this.mapx * w + w * this.originX;
      this.y = this.mapy * h + h * this.originY;
      if (this.mapx % 2 === 0) {
        this.y += h * 0.5;
      }
      return this;
    },
    setDirection: function(direction1) {
      var d;
      this.direction = direction1;
      d = DIRECTIONS[this.direction];
      this.body.rotation = d.rotation;
      this.gotoAndPlay(d.name);
      return this;
    },
    updateBattle: function() {
      var enemy, i, j, len, ref, scene;
      scene = this.getRoot();
      ref = scene.characterSprites;
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        enemy = ref[i];
        if (this.index !== i) {
          this._updateAttack(enemy);
        }
      }
    },
    calcRotation: function(p) {
      var r;
      r = Math.radToDeg(Math.atan2(p.y - this.y, p.x - this.x)) - this.body.rotation;
      if (r > 180) {
        r -= 360;
      } else if (r < -180) {
        r += 360;
      }
      return r;
    },

    /** 座標方向確認。
    * キャラクターの向いている方向を考慮し、指定された座標が、キャラクターからみてどの方向にあるか確認する。
    * @param {number} param.x          mapSprite の local X座標
    * @param {number} param.y          mapSprite の local Y座標
    * @param {number} param.start      確認する開始角度 -180 ～ 180
    * @param {number} param.end        確認する終了角度 -180 ～ 180
    * @param {Function} param.callback チェック結果をもらう関数
     */
    checkDirection: function(param) {
      var anticlockwise, callback, end, r, r1, r2, ra, res, start;
      r = param.r, start = param.start, end = param.end, anticlockwise = param.anticlockwise, callback = param.callback;
      if (r == null) {
        r = this.calcRotation(param);
      }
      r1 = anticlockwise ? end : start;
      r2 = anticlockwise ? start : end;
      res = false;
      if (r1 < r2) {
        res = r1 <= r && r <= r2;
      } else {
        res = r1 <= r || r <= r2;
      }
      if (callback != null) {
        if (!res) {
          if (r1 > r) {
            ra = r1;
          }
          if (r > r2) {
            ra = r2;
          }
        }
        callback(res, ra);
      }
      return res;
    },
    _checkAttackDirection: function(p) {
      p.x -= this.width / 2;
      p.y -= this.height / 2;
      if (this.checkDirection(p)) {
        return true;
      }
      p.x += this.width;
      if (this.checkDirection(p)) {
        return true;
      }
      p.y += this.height;
      if (this.checkDirection(p)) {
        return true;
      }
      p.x -= this.width;
      if (this.checkDirection(p)) {
        return true;
      }
      return false;
    },
    _updateAttack: function(enemy) {
      var cw, distance, p;
      if (!this.attack) {
        return;
      }
      if (this.character.team === enemy.character.team) {
        return;
      }
      cw = this.character.weapon;
      distance = enemy.position.distance(this.position);
      if (distance < (cw.height + this.body.width / 2)) {
        p = enemy.position.clone().$extend(cw.rotation);
        if (this._checkAttackDirection(p)) {
          this.attackAnimation();
          this.attack = false;
        }
      }
    },
    _enterframeWeapon: function(e) {
      var enemy, i, j, len, ref, scene;
      if (!this.weapon.visible) {
        return;
      }
      scene = this.getRoot();
      ref = scene.characterSprites;
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        enemy = ref[i];
        if (this.index !== i && !this._weaponHitFlag[i]) {
          if (this._isHitWeapon(enemy)) {
            enemy.flare('hitWeapon', {
              owner: this
            });
            this._weaponHitFlag[i] = true;
          }
        }
      }
    },
    _isHitWeapon: function(enemy) {
      var j, ref, rt, w;
      for (w = j = 16, ref = this.weapon.width; j < ref; w = j += 8) {
        rt = tm.geom.Vector2(0, 0);
        rt.setDegree(this.weapon.rotation + this.body.rotation, w);
        rt = this.localToGlobal(rt);
        if (enemy.isHitPoint(rt.x, rt.y)) {
          return true;
        }
      }
      return false;
    },
    startAction: function(turn) {
      var action, command, j, len, ref;
      this.tweener.clear();
      this.move = false;
      this.action = true;
      this.mapx = this.character.mapx;
      this.mapy = this.character.mapy;
      this.direction = this.character.direction;
      command = this.character.commands[turn];
      if (command != null) {
        this.attack = command.attack;
        ref = command.actions;
        for (j = 0, len = ref.length; j < len; j++) {
          action = ref[j];
          if (action.shot != null) {
            this._setShotAction(action.shot);
          }
          if (action.move != null) {
            this._setMoveAction(action.move);
          }
          if (action.rotate != null) {
            this._setRotateAction(action.rotate);
          }
          if (this.attack) {
            this.tweener.call(this.updateBattle, this, []);
          }
        }
      }
      this.tweener.call(this._endAction, this, []);
    },
    applyPosition: function() {
      this.character.mapx = this.mapx;
      this.character.mapy = this.mapy;
      this.character.direction = this.direction;
    },
    _endAction: function() {
      this.applyPosition();
      this.move = false;
      this.action = false;
      if (this.attack) {
        this.updateBattle();
        this.update = this.updateBattle;
      }
      this.tweener.clear();
    },
    isMove: function() {
      return this.move;
    },
    isStop: function() {
      return !this.move;
    },
    _setShotAction: function(param) {
      this.tweener.call(this.shotAnimation, this, [param]);
    },
    _setMoveAction: function(param) {
      var h, speed, w, x, y;
      this.move = true;
      this.mapx = param.mapx, this.mapy = param.mapy, speed = param.speed;
      w = MAP_CHIP_W;
      h = MAP_CHIP_H;
      x = this.mapx * w + w * this.originX;
      y = this.mapy * h + h * this.originY;
      if (this.mapx % 2 === 0) {
        y += h * 0.5;
      }
      this.tweener.move(x, y, speed);
    },
    _setBackAction: function(param) {},
    _setRotateAction: function(param) {
      var direction, speed;
      direction = param.direction, speed = param.speed;
      this.tweener.wait(speed);
      return this.tweener.call(this.directionAnimation, this, [direction]);
    },
    directionAnimation: function(direction) {
      return this.setDirection(direction);
    },
    attackAnimation: function() {
      var action, cw, finish;
      action = this.action;
      this.action = true;
      finish = function() {
        this.weapon.visible = false;
        this.weapon.rotation = 0;
        this.tweener.play();
        return this.action = action;
      };
      this.tweener.pause();
      cw = this.character.weapon;
      this.weapon.visible = true;
      this.weapon.rotation = cw.rotation.start;
      return this.weapon.tweener.clear().wait(50).rotate(cw.rotation.end, cw.speed).call(finish, this, []);
    },
    shotAnimation: function(param) {
      var angle, ballet, bv, distance, einfo, finish, rotation, scene, speed, vx, vy;
      rotation = param.rotation, distance = param.distance, speed = param.speed;
      scene = this.getRoot();
      bv = scene.mapSprite.globalToLocal(this.localToGlobal(this.body.position));
      ballet = tm.display.CircleShape({
        x: bv.x,
        y: bv.y,
        width: 10,
        height: 10
      }).addChildTo(scene.mapSprite);
      angle = Math.degToRad(rotation);
      vx = distance * Math.cos(angle) + bv.x;
      vy = distance * Math.sin(angle) + bv.y;
      speed = speed * distance / 32;
      einfo = {
        ballet: ballet,
        owner: this
      };
      finish = function() {
        ballet.remove();
        return scene.flare('removeBallet', einfo);
      };
      ballet.tweener.move(vx, vy, speed).call(finish, this, []);
      ballet.on('collisionenter', function(e) {
        e.other.flare('hitBallet', einfo);
        return ballet.tweener.clear().call(finish, this, []);
      });
      return scene.flare('addBallet', einfo);
    },
    _hitBallet: function(shooter, ballet) {
      console.log("hit ballet " + this.character.name);
    },
    _hitWeapon: function(attacker) {
      console.log("hit weapon " + this.character.name);
    }
  });

}).call(this);


/**
* @file SpriteStatus.coffee
* ステータス表示用スプライト
 */

(function() {
  tm.define('nz.SpriteStatus', {
    superClass: tm.display.CanvasElement,
    init: function(param) {
      var gaugebBrderColor;
      this.index = param.index, this.character = param.character, this.detail = param.detail;
      this.superInit();
      this.setOrigin(0.0, 0.0);
      this.width = 32 * 5;
      this.height = 32 * 2.5;
      this.alpha = 1.0;
      this.boundingType = 'rect';
      this.interactive = true;
      this.checkHierarchy = true;
      this.bgColor = 'blanchedalmond';
      gaugebBrderColor = 'gray';
      this.fromJSON({
        children: {
          bg: {
            type: 'RoundRectangleShape',
            width: this.width,
            height: this.height,
            strokeStyle: 'black',
            fillStyle: this.bgColor,
            lineWidth: 1,
            shadowBlur: 1,
            shadowOffsetX: 2,
            shadowOffsetY: 2,
            shadowColor: 'gray',
            originX: this.originX,
            originY: this.originY
          },
          name: {
            type: 'Label',
            text: this.character.name,
            fillStyle: 'black',
            align: 'left',
            baseline: 'top',
            x: 8,
            y: 10,
            originX: this.originX,
            originY: this.originY,
            fontSize: 8
          },
          action: {
            type: 'Label',
            fillStyle: 'black',
            align: 'left',
            baseline: 'top',
            x: 8,
            y: 20,
            originX: this.originX,
            originY: this.originY,
            fontSize: 8
          },
          hpGauge: {
            type: 'tm.ui.FlatGauge',
            x: 8,
            y: 32,
            width: this.width - 16,
            height: 4,
            originX: this.originX,
            originY: this.originY,
            borderWidth: 1,
            color: 'blue',
            bgColor: this.bgColor,
            borderColor: gaugebBrderColor
          },
          mpGauge: {
            type: 'tm.ui.FlatGauge',
            x: 8,
            y: 40,
            width: this.width - 16,
            height: 4,
            originX: this.originX,
            originY: this.originY,
            borderWidth: 1,
            color: 'green',
            bgColor: this.bgColor,
            borderColor: gaugebBrderColor
          },
          spGauge: {
            type: 'tm.ui.FlatGauge',
            x: 8,
            y: 48,
            width: this.width - 16,
            height: 4,
            originX: this.originX,
            originY: this.originY,
            borderWidth: 1,
            color: 'Cyan',
            bgColor: this.bgColor,
            borderColor: gaugebBrderColor
          }
        }
      });
      return this.on('refreshStatus', function(e) {
        var actions, text, turn;
        turn = e.turn;
        text = '行動: ';
        if (this.detail) {
          actions = [];
          if (this.character.isAttackAction(turn)) {
            actions.push('Attack');
          }
          if (this.character.isShotAction(turn)) {
            actions.push('Shot');
          }
          if (this.character.isMoveAction(turn)) {
            actions.push('Move');
          }
          text += actions.join(' & ');
          text += " (" + (this.character.ap - this.character.getActionCost(turn)) + ")";
        } else {
          text += '？？？';
        }
        return this.action.text = text;
      });
    }
  });

}).call(this);


/**
* @file SceneBase.coffee
* シーンベース
 */

(function() {
  var SCREEN_H, SCREEN_W;

  SCREEN_W = nz.system.screen.width;

  SCREEN_H = nz.system.screen.height;

  tm.define('nz.SceneBase', {
    superClass: tm.app.Scene,
    init: function() {
      this.superInit();
    },
    fireAll: function(e, param) {
      if (param == null) {
        param = {};
      }
      if (typeof e === 'string') {
        e = tm.event.Event(e);
        e.app = this.app;
        e.$extend(param);
      }
      this._dispatchEvent(e);
    },
    _dispatchEvent: function(e, element) {
      var child, i, len, ref;
      if (element == null) {
        element = this;
      }
      if (element.hasEventListener(e.type)) {
        element.fire(e);
      }
      ref = element.children;
      for (i = 0, len = ref.length; i < len; i++) {
        child = ref[i];
        this._dispatchEvent(e, child);
      }
    },
    openMenuDialog: function(_param) {
      var dlg, m, menuFunc, param;
      param = {
        screenWidth: SCREEN_W,
        screenHeight: SCREEN_H
      }.$extend(_param);
      menuFunc = (function() {
        var i, len, ref, results;
        ref = param.menu;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          m = ref[i];
          if (m.func != null) {
            results.push(m.func);
          }
        }
        return results;
      })();
      param.menu = (function() {
        var i, len, ref, results;
        ref = param.menu;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          m = ref[i];
          if (m.name != null) {
            results.push(m.name);
          }
        }
        return results;
      })();
      dlg = tm.ui.MenuDialog(param);
      dlg.on('menuclosed', function(e) {
        var ref;
        return (ref = menuFunc[e.selectIndex]) != null ? ref.call(null, e.selectIndex) : void 0;
      });
      dlg.box.setStrokeStyle(nz.system.dialog.strokeStyle);
      dlg.box.setFillStyle(nz.system.dialog.fillStyle);
      this.app.pushScene(dlg);
      return dlg;
    },
    description: function(text) {
      if (!this._description) {
        this._description = tm.display.Label('', 14).addChildTo(this).setAlign('center').setBaseline('middle').setPosition(SCREEN_W / 2, SCREEN_H - 10);
      }
      return this._description.text = text;
    }
  });

}).call(this);


/**
* @file SceneTitleMenu.coffee
* タイトルシーン
 */

(function() {
  tm.define('nz.SceneTitleMenu', {
    superClass: tm.ui.MenuDialog,

    /** 初期化
    * @classdesc タイトルシーンクラス
    * @constructor nz.SceneTitleMenu
     */
    init: function() {
      var menu, menus;
      menus = [
        {
          name: 'New Game',
          desctiption: '新しいゲームをはじめる',
          callback: this._new_game
        }, {
          name: 'Load Game',
          desctiption: '保存したゲームをはじめる',
          callback: this._load_game
        }, {
          name: 'Option',
          desctiption: 'ゲームオプション',
          callback: this._option
        }, {
          name: 'Debug',
          desctiption: 'デバック',
          callback: this._debug_game
        }
      ];
      this.superInit({
        title: nz.system.title,
        screenWidth: nz.system.screen.width,
        screenHeight: nz.system.screen.height,
        menu: (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = menus.length; i < len; i++) {
            menu = menus[i];
            results.push(menu.name);
          }
          return results;
        })(),
        menuDesctiptions: (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = menus.length; i < len; i++) {
            menu = menus[i];
            results.push(menu.desctiption);
          }
          return results;
        })()
      });
      this.box.setStrokeStyle(nz.system.dialog.strokeStyle);
      this.box.setFillStyle(nz.system.dialog.fillStyle);
      this.index = 0;
      this.on('menuselected', function(e) {
        return this.index = e.selectIndex;
      });
      this.on('exit', function(e) {
        return menus[this.index].callback.call(this, e);
      });
      this.on('enter', function(e) {
        return this.app.pushScene(tm.game.TitleScene({
          title: nz.system.title
        }));
      });
    },

    /** 新しいゲームを開始
    * @constructor nz.SceneTitleMenu#
     */
    _new_game: function() {
      this.app.pushScene(nz.SceneBattle({
        mapId: 1,
        controlTeam: ['teamA'],
        characters: [
          nz.Character({
            name: 'キャラクター1',
            team: 'teamA'
          }), nz.Character({
            name: 'キャラクター2',
            team: 'teamA'
          }), nz.Character({
            name: 'キャラクター3',
            team: 'teamA'
          }), nz.Character({
            name: 'キャラクター4',
            team: 'teamB'
          }), nz.Character({
            name: 'キャラクター5',
            team: 'teamB'
          }), nz.Character({
            name: 'キャラクター6',
            team: 'teamB'
          })
        ]
      }));
    },

    /** ゲームをロード
    * @constructor nz.SceneTitleMenu#
     */
    _load_game: function() {
      console.log('load game');
    },

    /** システムオプション
    * @constructor nz.SceneTitleMenu#
     */
    _option: function() {
      console.log('option');
    },

    /** 新しいゲームを開始
    * @constructor nz.SceneTitleMenu#
     */
    _debug_game: function() {
      this.app.pushScene(nz.SceneBattle({
        mapId: 0,
        controlTeam: ['teamA'],
        characters: [
          nz.Character({
            name: 'キャラクター1',
            team: 'teamA'
          }), nz.Character({
            name: 'キャラクター2',
            team: 'teamA'
          }), nz.Character({
            name: 'キャラクター3',
            team: 'teamA'
          }), nz.Character({
            name: 'キャラクター4',
            team: 'teamB'
          }), nz.Character({
            name: 'キャラクター5',
            team: 'teamB'
          }), nz.Character({
            name: 'キャラクター6',
            team: 'teamB'
          })
        ]
      }));
    }
  });

}).call(this);


/**
* @file SceneBattle.coffee
* 戦闘シーン
 */

(function() {
  var ACTION_COST, DIRECTIONS, SCREEN_H, SCREEN_W;

  SCREEN_W = nz.system.screen.width;

  SCREEN_H = nz.system.screen.height;

  DIRECTIONS = nz.system.character.directions;

  ACTION_COST = nz.system.character.action_cost;

  tm.define('nz.SceneBattle', {
    superClass: nz.SceneBase,

    /** 初期化
    * @classdesc 戦闘シーンクラス
    * @constructor nz.SceneBattle
     */
    init: function(param) {
      this.mapId = param.mapId, this.characters = param.characters, this.controlTeam = param.controlTeam;
      this.superInit();
      this.mapName = 'map_' + ("" + this.mapId).paddingLeft(3, '0');
      this._selectCharacterIndex = 0;
      this.data = {
        turn: 0
      };
      this.on('enter', this.load.bind(this));
    },
    load: function() {
      var assets, c, j, len, loaded, ref, scene;
      loaded = true;
      assets = {};
      if (!tm.asset.Manager.contains(this.mapName)) {
        assets[this.mapName] = "data/" + this.mapName + ".json";
        loaded = false;
      }
      ref = this.characters;
      for (j = 0, len = ref.length; j < len; j++) {
        c = ref[j];
        if (!(!tm.asset.Manager.contains(c.ai.name))) {
          continue;
        }
        assets[c.ai.name] = c.ai.src;
        loaded = false;
      }
      if (!loaded) {
        scene = tm.game.LoadingScene({
          assets: assets,
          width: SCREEN_W,
          height: SCREEN_H,
          autopop: true
        });
        scene.on('load', this.setup.bind(this));
        this.app.pushScene(scene);
      } else {
        this.setup();
      }
    },
    setup: function() {
      var character, i, j, len, ref, scene, x, y;
      scene = this;
      this.mapSprite = nz.SpriteBattleMap(this.mapName).addChildTo(this);
      this.mapSprite.x = (SCREEN_W - this.mapSprite.width) / 2;
      this.mapSprite.y = (SCREEN_H - this.mapSprite.height) / 2;
      this.status = tm.display.CanvasElement().addChildTo(this);
      x = y = 0;
      ref = this.characters;
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        character = ref[i];
        this.characterSprites.push(nz.SpriteCharacter(i, character).setVisible(false).addChildTo(this.mapSprite));
      }
      this.characterSprites[0].setMapPosition(0, 0);
      this.characterSprites[0].applyPosition();
      this.characterSprites[0].setVisible(true);
      this.characterSprites[0].character.move.speed = 150;
      this.on('map.pointingend', this.mapPointingend);
      this.one('enterframe', function() {
        return this._startInputPhase();
      });
      this.refreshStatus();
    },
    mapPointingend: function(e) {
      var direction, mapx, mapy, ref, route;
      ref = this.characters[0], direction = ref.direction, mapx = ref.mapx, mapy = ref.mapy;
      route = this.mapSprite.graph.searchRoute(direction, mapx, mapy, e.mapx, e.mapy);
      this.selectCharacter.addMoveCommand(this.turn, route);
      this._pushScene(nz.SceneBattleTurn({
        start: this.turn,
        end: this.turn,
        mapSprite: this.mapSprite
      }));
      this.one('resume', function() {
        return this._startInputPhase();
      });
    },
    refreshStatus: function() {
      this.fireAll('refreshStatus', {
        turn: this.turn
      });
    },
    activeStatus: function(status) {
      this.status.addChild(status);
    },
    blinkCharacter: function(index) {
      var s;
      s = this.characterSprites[index];
      this.mapSprite.clearBlink();
      this.mapSprite.blink(s.mapx, s.mapy);
      if (s.hasGhost()) {
        this.mapSprite.blink(s.ghost.mapx, s.ghost.mapy);
      }
    },
    _pushScene: function(scene) {
      this.one('pause', function() {
        return this.mapSprite.addChildTo(scene);
      });
      this.one('resume', function() {
        return this.mapSprite.addChildTo(this);
      });
      this.mapSprite.remove();
      this.app.pushScene(scene);
    },
    _commandScene: function(klass, callback) {
      var target;
      this.refreshStatus();
      target = this.selectCharacterSprite;
      if (this._selectGhost) {
        target = this.selectCharacterSprite.ghost;
      }
      this._pushScene(klass({
        turn: this.turn,
        target: target,
        callback: callback,
        mapSprite: this.mapSprite
      }));
      this.one('resume', this._checkCommandConf.bind(this));
    },
    _openMainMenu: function() {
      this.openMenuDialog({
        title: 'Command?',
        menu: [
          {
            name: 'Next Turn',
            func: this._openCommandConf.bind(this)
          }, {
            name: 'Option',
            func: function(e) {}
          }, {
            name: 'Exit Game',
            func: this._exitGame.bind(this)
          }, {
            name: 'Close Menu'
          }
        ]
      });
    },
    _openCharacterSelectMenu: function(targets) {
      var j, len, menu, t;
      menu = [];
      for (j = 0, len = targets.length; j < len; j++) {
        t = targets[j];
        menu.push({
          name: t.character.name,
          func: (function(i) {
            return this._openCharacterMenu(targets[i]);
          }).bind(this)
        });
      }
      menu.push({
        name: 'Close Menu'
      });
      this.openMenuDialog({
        title: 'Select Character',
        menu: menu
      });
    },
    _openCharacterMenu: function(target) {
      var acost, attack, j, len, menu, rap, ref, s, sc, shot;
      this._selectCharacterIndex = target.index;
      this._selectGhost = target.isGhost();
      ref = this.status.children;
      for (j = 0, len = ref.length; j < len; j++) {
        s = ref[j];
        if (s.index === target.index) {
          this.activeStatus(s);
        }
      }
      menu = [];
      sc = this.selectCharacter;
      acost = sc.getActionCost(this.turn);
      rap = sc.getRemnantAp(this.turn);
      if (this._selectGhost || (!this._selectGhost && !target.hasGhost())) {
        if (rap > 0) {
          menu.push({
            name: 'Move',
            func: this._addMoveCommand.bind(this)
          });
          menu.push({
            name: 'Direction',
            func: this._addRotateCommand.bind(this)
          });
        }
        if (rap >= ACTION_COST.attack) {
          attack = sc.isAttackAction(this.turn);
          shot = sc.isShotAction(this.turn);
          if (!attack && !shot) {
            menu.push({
              name: 'Attack',
              func: this._addAttackCommand.bind(this)
            });
            menu.push({
              name: 'Shot',
              func: this._addShotCommand.bind(this)
            });
          }
        }
      }
      if (acost > 0) {
        menu.push({
          name: 'Reset Action',
          func: this._resetAction.bind(this)
        });
      }
      menu.push({
        name: 'Close Menu'
      });
      this.openMenuDialog({
        title: sc.name,
        menu: menu
      });
    },
    _openCommandConf: function() {
      this.openMenuDialog({
        title: 'Start Battle?',
        menu: [
          {
            name: 'Yes',
            func: this._startBattlePhase.bind(this)
          }, {
            name: 'No'
          }
        ]
      });
    },
    _checkCommandConf: function() {
      var c, j, len, ref;
      ref = this.characters;
      for (j = 0, len = ref.length; j < len; j++) {
        c = ref[j];
        if (this.controlTeam.contains(c.team)) {
          if (c.getRemnantAp(this.turn) > 0) {
            return;
          }
        }
      }
      this._openCommandConf();
    },
    _exitGame: function() {
      this.app.replaceScene(nz.SceneTitleMenu());
    },
    _startInputPhase: function() {
      var c, characters, i, j, len, ref;
      this.mapSprite.cursor.visible = true;
      this.data.turn += 1;
      characters = (function() {
        var j, len, ref, results;
        ref = this.characters;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          c = ref[j];
          results.push(c.createAiInfo());
        }
        return results;
      }).call(this);
      for (i = j = 0, len = characters.length; j < len; i = ++j) {
        c = characters[i];
        if (!(!(this.controlTeam.contains(c.team)))) {
          continue;
        }
        if ((ref = nz.system.ai[c.ai.name]) != null) {
          ref.setupAction({
            character: c,
            characters: characters,
            graph: this.mapSprite.graph,
            turn: this.turn
          });
        }
        this.characters[i].commands[this.turn] = c.commands[this.turn];
      }
      return this.refreshStatus();
    },
    _startBattlePhase: function() {
      this.refreshStatus();
      this._pushScene(nz.SceneBattleTurn({
        start: this.turn,
        end: this.turn,
        mapSprite: this.mapSprite
      }));
      this.one('resume', function() {
        return this._startInputPhase();
      });
    },
    _addMoveCommand: function() {
      this._commandScene(nz.SceneBattleMoveCommand, (function(route) {
        var p;
        this.selectCharacter.addMoveCommand(this.turn, route);
        if (route.length > 0) {
          p = route[route.length - 1];
          this.selectCharacterSprite.createGhost(p.direction, p.mapx, p.mapy).addChildTo(this.mapSprite);
        }
        this.refreshStatus();
      }).bind(this));
    },
    _addAttackCommand: function() {
      var sc, scs;
      sc = this.selectCharacter;
      sc.setAttackCommand(this.turn);
      scs = this.selectCharacterSprite;
      if (!scs.hasGhost() && !scs.isGhost()) {
        scs.createGhost(scs.direction, scs.mapx, scs.mapy).addChildTo(this.mapSprite);
      }
      this.refreshStatus();
      if (sc.getRemnantAp(this.turn) > 0) {
        this._selectGhost = true;
        this.one('enterframe', this._addMoveCommand);
      } else {
        this._checkCommandConf();
      }
    },
    _addShotCommand: function() {
      this._commandScene(nz.SceneBattleShotCommand, (function(rotation) {
        var sc, scs;
        sc = this.selectCharacter;
        scs = this.selectCharacterSprite;
        sc.addShotCommand(this.turn, rotation);
        if (!scs.hasGhost() && !scs.isGhost()) {
          scs.createGhost(scs.direction, scs.mapx, scs.mapy).addChildTo(this.mapSprite);
        }
        this.refreshStatus();
        if (sc.getRemnantAp(this.turn) > 0) {
          this._selectGhost = true;
          this.one('enterframe', this._addMoveCommand);
        }
      }).bind(this));
    },
    _addRotateCommand: function() {
      this._commandScene(nz.SceneBattleDirectionCommand, (function(direction1, direction2) {
        var s, sc, scs;
        sc = this.selectCharacter;
        scs = this.selectCharacterSprite;
        sc.addRotateCommand(this.turn, direction1, DIRECTIONS[direction1].rotateIndex[direction2]);
        if (!scs.hasGhost()) {
          s = scs;
          s.createGhost(direction2, s.mapx, s.mapy).addChildTo(this.mapSprite);
        } else {
          scs.ghost.setDirection(direction2);
        }
        this.refreshStatus();
        if (sc.getRemnantAp(this.turn) > 0) {
          this._selectGhost = true;
          this.one('enterframe', this._addMoveCommand);
        }
      }).bind(this));
    },
    _resetAction: function() {
      this.selectCharacter.clearAction();
      this.selectCharacterSprite.clearGhost();
    }
  });

  nz.SceneBattle.prototype.getter('characterSprites', function() {
    return this.mapSprite.characterSprites;
  });

  nz.SceneBattle.prototype.getter('selectCharacterSprite', function() {
    return this.characterSprites[this._selectCharacterIndex];
  });

  nz.SceneBattle.prototype.getter('selectCharacter', function() {
    return this.selectCharacterSprite.character;
  });

  nz.SceneBattle.prototype.getter('turn', function() {
    return this.data.turn;
  });

}).call(this);


/**
* @file SceneBattlePosition.coffee
* 戦闘開始位置設定
 */

(function() {
  var DIRNUM, MSGS;

  MSGS = nz.system.MESSAGES;

  DIRNUM = nz.system.DIRECTION_NUM;

  tm.define('nz.SceneBattlePosition', {
    superClass: nz.SceneBase,
    init: function(param) {
      var area, areaIndex, c, i, j, k, l, len, len1, len2, m, member, members, p, ref, ref1, ref2, ref3, team;
      this.superInit();
      this.mapSprite = param.mapSprite, this.controlTeam = param.controlTeam;
      this.otherTeam = [];
      this.teamArea = {};
      this.members = {};
      areaIndex = 0;
      ref = this.mapSprite.characterSprites;
      for (j = 0, len = ref.length; j < len; j++) {
        c = ref[j];
        team = c.character.team;
        if (this.members[team] == null) {
          this.members[team] = [];
          this.teamArea[team] = this.mapSprite.map.start.area[areaIndex].clone();
          if (!this.controlTeam.contains(team)) {
            this.otherTeam.push(team);
          }
          areaIndex += 1;
        }
        this.members[team].push(c);
      }
      ref1 = this.otherTeam;
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        team = ref1[k];
        area = this.teamArea[team];
        members = (function() {
          var l, len2, ref2, results;
          ref2 = this.members[team];
          results = [];
          for (l = 0, len2 = ref2.length; l < len2; l++) {
            m = ref2[l];
            results.push(m.character);
          }
          return results;
        }).call(this);
        ref2 = this.members[team];
        for (i = l = 0, len2 = ref2.length; l < len2; i = ++l) {
          member = ref2[i];
          c = member.character;
          p = (ref3 = nz.system.ai[c.ai.name]) != null ? ref3.setupBattlePosition({
            character: c,
            members: members,
            area: area
          }) : void 0;
          if (p == null) {
            p = area[i];
          }
          this._setBattlePosition(member, p[0], p[1]);
          member.applyPosition();
        }
      }
      this.on('map.pointingover', this._mapPointingover);
      this.on('map.pointingend', this._mapPointingend);
      this.on('enter', this._start);
    },
    _test: function(e) {
      var j, k, ref, ref1, x, y;
      this.mapSprite.cursor.visible = true;
      this.mapSprite.clearBlink();
      for (x = j = 0, ref = this.mapSprite.map.width; 0 <= ref ? j < ref : j > ref; x = 0 <= ref ? ++j : --j) {
        for (y = k = 0, ref1 = this.mapSprite.map.height; 0 <= ref1 ? k < ref1 : k > ref1; y = 0 <= ref1 ? ++k : --k) {
          if (nz.system.ai['SampleAI'].calcDistance({
            x: e.mapx,
            y: e.mapy
          }, {
            x: x,
            y: y
          }) <= 3) {
            this.mapSprite.blink(x, y);
          }
        }
      }
    },
    _start: function() {
      var c, j, len, ref;
      ref = this.mapSprite.characterSprites;
      for (j = 0, len = ref.length; j < len; j++) {
        c = ref[j];
        if (!(!c.visible)) {
          continue;
        }
        this._selectCharacter(c);
        this.description(MSGS.battle.position.setiing.format({
          name: c.character.name
        }));
        return;
      }
    },
    _end: function() {
      var c, j, len, mapycenter, ref;
      mapycenter = this.mapSprite.map.width / 2;
      ref = this.mapSprite.characterSprites;
      for (j = 0, len = ref.length; j < len; j++) {
        c = ref[j];
        c.visible = true;
        if (c.mapy < mapycenter) {
          c.character.direction = DIRNUM.DOWN;
          c.setDirection(DIRNUM.DOWN);
        } else {
          c.character.direction = DIRNUM.UP;
          c.setDirection(DIRNUM.UP);
        }
      }
      this.mapSprite.clearBlink();
      this.one('enterframe', function() {
        return this.app.popScene();
      });
    },
    _openCharacterMenu: function() {
      var c, characters, j, k, len, len1, menu, ref, ref1, team;
      this.mapSprite.clearBlink();
      this.mapSprite.cursor.visible = false;
      characters = [];
      menu = [];
      ref = this.controlTeam;
      for (j = 0, len = ref.length; j < len; j++) {
        team = ref[j];
        ref1 = this.members[team];
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          c = ref1[k];
          if (!(!c.visible)) {
            continue;
          }
          characters.push(c);
          menu.push({
            name: c.character.name,
            func: (function(i) {
              return this._selectCharacter(characters[i]);
            }).bind(this)
          });
        }
      }
      return this.openMenuDialog({
        title: 'Character',
        menu: menu
      });
    },
    _selectCharacter: function(character) {
      var j, len, m, ref, results;
      this.character = character;
      this.mapSprite.clearBlink();
      ref = this.teamArea[this.character.character.team];
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        m = ref[j];
        if (this.mapSprite.findCharacter(m[0], m[1]).length === 0) {
          results.push(this.mapSprite.blink(m[0], m[1]));
        } else {
          results.push(void 0);
        }
      }
      return results;
    },
    _setBattlePosition: function(c, mapx, mapy) {
      c.setMapPosition(mapx, mapy);
      if (c.mapy < this.mapSprite.map.width / 2) {
        c.setDirection(DIRNUM.DOWN);
      } else {
        c.setDirection(DIRNUM.UP);
      }
    },
    _mapPointingover: function(e) {
      this.mapSprite.cursor.visible = true;
      this.character.visible = true;
      this._setBattlePosition(this.character, e.mapx, e.mapy);
      this.character.applyPosition();
    },
    _mapPointingend: function(e) {
      var c, j, k, len, len1, ref, ref1, team;
      if (this.mapSprite.isBlink(e.mapx, e.mapy)) {
        this._mapPointingover(e);
        ref = this.controlTeam;
        for (j = 0, len = ref.length; j < len; j++) {
          team = ref[j];
          ref1 = this.members[team];
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            c = ref1[k];
            if (!(!c.visible)) {
              continue;
            }
            this._start();
            return;
          }
        }
        this._end();
      }
    }
  });

}).call(this);


/**
* @file SceneBattleMoveCommand.coffee
* 移動コマンド
 */

(function() {
  tm.define('nz.SceneBattleMoveCommand', {
    superClass: tm.app.Scene,
    init: function(param) {
      this.superInit();
      this.turn = param.turn, this.target = param.target, this.callback = param.callback, this.mapSprite = param.mapSprite;
      this.on('map.pointingover', this._over);
      return this.on('map.pointingend', this._end);
    },
    searchRoute: function(emapx, emapy) {
      var direction, mapx, mapy, ref;
      ref = this.target, direction = ref.direction, mapx = ref.mapx, mapy = ref.mapy;
      return this.mapSprite.graph.searchRoute(direction, mapx, mapy, emapx, emapy);
    },
    commandAp: function() {
      return this.target.character.ap - this.target.character.getActionCost(this.turn);
    },
    _end: function(e) {
      if (this.mapSprite.isBlink(e.mapx, e.mapy)) {
        this.callback(this.searchRoute(e.mapx, e.mapy));
      }
      this.mapSprite.clearBlink();
      this.one('enterframe', function() {
        return this.app.popScene();
      });
    },
    _over: function(e) {
      var ap, i, len, r, results, route;
      this.mapSprite.clearBlink();
      ap = this.commandAp();
      route = this.searchRoute(e.mapx, e.mapy);
      results = [];
      for (i = 0, len = route.length; i < len; i++) {
        r = route[i];
        if (r.cost <= ap) {
          results.push(this.mapSprite.blink(r.mapx, r.mapy));
        }
      }
      return results;
    }
  });

}).call(this);


/**
* @file SceneBattleShotCommand.coffee
* 射撃コマンドシーン
 */

(function() {
  tm.define('nz.SceneBattleShotCommand', {
    superClass: tm.app.Scene,
    init: function(param) {
      this.superInit();
      this.turn = param.turn, this.target = param.target, this.callback = param.callback, this.mapSprite = param.mapSprite;
      this.costa = this.target.character.getActionCost(this.turn);
      this.on('map.pointingend', this._pointEnd);
      return this._createPointer();
    },
    update: function(app) {
      this._movePointer(app.pointing);
    },
    _pointStart: function(e) {
      this._movePointer(e.pointing);
    },
    _pointMove: function(e) {
      this._movePointer(e.pointing);
    },
    _pointEnd: function(e) {
      this._setupCommand();
      this._removePointer();
      this._endScene();
    },
    _setupCommand: function() {
      if (this.pointer != null) {
        this.callback(this.pointer.rotation);
      }
    },
    _endScene: function() {
      this.one('enterframe', function() {
        return this.app.popScene();
      });
    },
    _createPointer: function() {
      this.pointer = tm.display.Shape({
        width: 10,
        height: 10
      }).addChildTo(this.mapSprite).setPosition(this.target.x, this.target.y);
      tm.display.CircleShape({
        x: 40,
        width: 10,
        height: 10,
        fillStyle: 'blue'
      }).addChildTo(this.pointer);
      this.pointer.rotation = this.target.body.rotation;
    },
    _removePointer: function() {
      if (this.pointer != null) {
        this.pointer.remove();
        this.pointer = null;
      }
    },
    _movePointer: function(pointing) {
      var t, tcsr;
      if (this.pointer != null) {
        t = this.mapSprite.globalToLocal(pointing);
        tcsr = this.target.character.shot.rotation;
        this.target.checkDirection({
          x: t.x,
          y: t.y,
          start: tcsr.start,
          end: tcsr.end,
          anticlockwise: tcsr.anticlockwise,
          callback: (function(result, r) {
            var v, x, y;
            if (result) {
              x = t.x - this.target.x;
              y = t.y - this.target.y;
              v = tm.geom.Vector2(x, y);
              r = Math.radToDeg(v.toAngle());
            } else {
              r += this.target.body.rotation;
            }
            return this.pointer.rotation = r;
          }).bind(this)
        });
      }
    }
  });

}).call(this);


/**
* @file SceneBattleDirectionCommand.coffee
* 向き設定コマンドシーン
 */

(function() {
  var DIRECTIONS;

  DIRECTIONS = nz.system.character.directions;

  tm.define('nz.SceneBattleDirectionCommand', {
    superClass: nz.SceneBattleShotCommand,
    init: function(param) {
      this.superInit(param);
      return this._direction = null;
    },
    _setupCommand: function() {
      if (this._direction != null) {
        this.callback(this.target.direction, this._direction);
      }
    },
    _movePointer: function(pointing) {
      var costd, d, i, j, len, rotation, t, v, x, y;
      if (this.pointer == null) {
        return;
      }
      t = this.target.body.localToGlobal(tm.geom.Vector2(0, 0));
      x = pointing.x - t.x;
      y = pointing.y - t.y;
      v = tm.geom.Vector2(x, y);
      rotation = Math.radToDeg(v.toAngle());
      for (i = j = 0, len = DIRECTIONS.length; j < len; i = ++j) {
        d = DIRECTIONS[i];
        if (0 <= i && i < 6) {
          if (d.rotation - 30 < rotation && rotation < d.rotation + 30) {
            costd = nz.GridNode.calcDirectionCost(this.target.direction, d.index);
            if ((this.costa + costd) <= this.target.character.ap) {
              if (this._direction !== d.index) {
                this._direction = d.index;
                this.pointer.rotation = d.rotation;
                return;
              }
            }
          }
        }
      }
    }
  });

}).call(this);


/**
* @file SceneBattleTurn.coffee
* 戦闘ターンシーン
 */

(function() {
  tm.define('nz.SceneBattleTurn', {
    superClass: tm.app.Scene,
    init: function(param) {
      var end, start;
      this.superInit();
      this.mapSprite = param.mapSprite, start = param.start, end = param.end;
      this.startTuen = start;
      this.endTurn = end;
      this.turn = start;
      this.runing = false;
      this._balletCount = 0;
      this.on('enter', this._startScene);
      this.on('addBallet', this._addBallet);
      this.on('removeBallet', this._removeBallet);
    },
    _removeBallet: function(param) {
      var ballet;
      ballet = param.ballet;
      return this._balletCount -= 1;
    },
    _addBallet: function(param) {
      var ballet, c, i, len, owner, ref;
      ballet = param.ballet, owner = param.owner;
      this._balletCount += 1;
      ref = this.characterSprites;
      for (i = 0, len = ref.length; i < len; i++) {
        c = ref[i];
        if (c !== owner) {
          ballet.collision.add(c);
        }
      }
    },
    _dispatchBattleEvent: function(e, element) {
      var child, i, len, ref;
      if (element == null) {
        element = this;
      }
      if (typeof e === 'string') {
        e = tm.event.Event(e);
        e.app = this.app;
        e.turn = this.turn;
      }
      if (element.hasEventListener(e.type)) {
        element.fire(e);
      }
      ref = element.children;
      for (i = 0, len = ref.length; i < len; i++) {
        child = ref[i];
        this._dispatchBattleEvent(e, child);
      }
    },
    _startScene: function() {
      this._dispatchBattleEvent('battleSceneStart');
      this._startTurn(this.startTuen);
    },
    _endScene: function() {
      this._dispatchBattleEvent('battleSceneEnd');
      this.app.popScene();
    },
    _startTurn: function(turn) {
      this.turn = turn;
      this._dispatchBattleEvent('battleTurnStart');
      this.update = this.updateTurn;
    },
    _endTurn: function() {
      this._dispatchBattleEvent('battleTurnEnd');
      this.update = null;
    },
    _isEnd: function() {
      return this.turn >= this.endTurn;
    },
    _isEndAllCharacterAction: function() {
      var character, flag, i, len, ref;
      flag = false;
      ref = this.characterSprites;
      for (i = 0, len = ref.length; i < len; i++) {
        character = ref[i];
        flag |= character.action;
      }
      return (!flag) && (this._balletCount === 0);
    },
    updateTurn: function() {
      if (this._isEndAllCharacterAction()) {
        this._endTurn();
        if (this._isEnd()) {
          this._endScene();
        } else {
          this._startTurn(this.turn + 1);
        }
      }
    }
  });

  nz.SceneBattleTurn.prototype.getter('characterSprites', function() {
    return this.mapSprite.characterSprites;
  });

}).call(this);

(function() {
  tm.main(function() {
    var app, assets, screen;
    screen = nz.system.screen;
    assets = nz.system.assets;
    app = tm.display.CanvasApp('#world');
    app.resize(screen.width, screen.height);
    app.fitWindow();
    app.background = 'gray';
    app.pushScene(tm.game.LoadingScene({
      assets: assets,
      width: screen.width,
      height: screen.height
    }).on('load', function() {
      this.app.replaceScene(nz.SceneBattle({
        mapId: 1,
        controlTeam: ['teamA'],
        characters: [
          nz.Character({
            name: 'キャラクター1',
            team: 'teamA'
          })
        ]
      }));
    }));
    return app.run();
  });

}).call(this);
