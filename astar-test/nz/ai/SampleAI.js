(function() {
  var _g, nz, ref, ref1;

  _g = typeof window !== "undefined" && window !== null ? window : global;

  nz = _g.nz = (ref = _g.nz) != null ? ref : {};

  _g = void 0;

  nz.ai = (ref1 = nz.ai) != null ? ref1 : {};

  nz.ai.SampleAI = (function() {
    function SampleAI() {
      this.rules = [
        {
          cond: function(param) {
            var character, characters, distance, friends, graph, ref2, target, targets, turn;
            character = param.character, characters = param.characters, graph = param.graph, friends = param.friends, targets = param.targets, turn = param.turn;
            ref2 = this.findNearTarget(character, targets), target = ref2.target, distance = ref2.distance;
            param.target = target;
            param.distance = distance;
            return false;
          }
        }, {
          cond: function(param) {
            var distance;
            distance = param.distance;
            return distance <= 4;
          },
          setup: function(param) {
            var character, graph, route, target, turn;
            character = param.character, turn = param.turn, graph = param.graph, target = param.target;
            route = this.searchRoute(graph, character, target);
            character.setAttackCommand(turn);
            character.addMoveCommand(turn, route);
          }
        }, {
          cond: function(param) {
            var distance;
            distance = param.distance;
            return distance >= 7;
          },
          setup: function(param) {
            var character, graph, route, target, turn;
            character = param.character, turn = param.turn, graph = param.graph, target = param.target;
            route = this.searchRoute(graph, character, target);
            character.addMoveCommand(turn, route);
          }
        }
      ];
    }

    SampleAI.prototype.searchRoute = function(graph, character, target) {
      var direction, mapx, mapy;
      direction = character.direction, mapx = character.mapx, mapy = character.mapy;
      return graph.searchRoute(direction, mapx, mapy, target.mapx, target.mapy);
    };

    SampleAI.prototype.distance = function(c1, c2) {
      var hr, hx, hy;
      hx = Math.abs(c1.mapx - c2.mapx);
      hy = Math.abs(c1.mapy - c2.mapy);
      hr = Math.ceil(hx / 2);
      if (hy < hr) {
        return hx;
      }
      if (hx % 2 === 1) {
        if (c1.mapx % 2 === 1) {
          if (c1.mapy <= c2.mapy) {
            hy += 1;
          }
        } else {
          if (c1.mapy >= c2.mapy) {
            hy += 1;
          }
        }
      }
      return hx + hy - hr;
    };

    SampleAI.prototype.direction = function(c1, c2) {
      var d;
      d = 0;
      if (c1.mapx === c2.mapx) {
        if (c1.mapy > c2.mapy) {
          d = 0;
        }
        if (c1.mapy < c2.mapy) {
          d = 3;
        }
      } else if (c1.mapx > c2.mapx) {
        if (c1.mapy === c2.mapy) {
          d = c1.mapx % 2 === 0 ? 5 : 4;
        } else if (c1.mapy > c2.mapy) {
          d = 5;
        } else if (c1.mapy < c2.mapy) {
          d = 4;
        }
      } else if (c1.mapx < c2.mapx) {
        if (c1.mapy === c2.mapy) {
          d = c1.mapx % 2 === 0 ? 1 : 2;
        } else if (c1.mapy > c2.mapy) {
          d = 1;
        } else if (c1.mapy < c2.mapy) {
          d = 2;
        }
      }
      return d;
    };

    SampleAI.prototype.findNearTarget = function(c, targets) {
      var d, j, len, result, t;
      result = {
        target: null,
        distance: 99
      };
      for (j = 0, len = targets.length; j < len; j++) {
        t = targets[j];
        d = this.distance(c, t);
        if (d < result.distance) {
          result.distance = d;
          result.target = t;
        }
      }
      return result;
    };

    SampleAI.prototype.setupBattlePosition = function(param) {
      var area, character, i, members;
      console.log('setupBattlePosition');
      character = param.character, members = param.members, area = param.area;
      i = members.indexOf(character);
      return area[i];
    };

    SampleAI.prototype.setupAction = function(param) {
      var c, character, characters, friends, j, k, len, len1, r, ref2, ref3, targets;
      console.log('setupAction');
      character = param.character, characters = param.characters;
      friends = [];
      targets = [];
      for (j = 0, len = characters.length; j < len; j++) {
        c = characters[j];
        if (c.name !== character.name) {
          if (character.team === c.team) {
            friends.push(c);
          } else {
            targets.push(c);
          }
        }
      }
      param.friends = friends;
      param.targets = targets;
      ref2 = this.rules;
      for (k = 0, len1 = ref2.length; k < len1; k++) {
        r = ref2[k];
        if (r.cond.call(this, param)) {
          if ((ref3 = r.setup) != null ? ref3.call(this, param) : void 0) {
            break;
          }
        }
      }
      return character;
    };

    return SampleAI;

  })();

  nz.system.addAI('SampleAI', new nz.ai.SampleAI());

}).call(this);
