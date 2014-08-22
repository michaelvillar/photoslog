window.dynamic = function() {
  (function() {
  if (!this.require) {
    var modules = {}, cache = {};

    var require = function(name, root) {
      var path = expand(root, name), indexPath = expand(path, './index'), module, fn;
      module   = cache[path] || cache[indexPath];
      if (module) {
        return module;
      } else if (fn = modules[path] || modules[path = indexPath]) {
        module = {id: path, exports: {}};
        cache[path] = module.exports;
        fn(module.exports, function(name) {
          return require(name, dirname(path));
        }, module);
        return cache[path] = module.exports;
      } else {
        throw 'module ' + name + ' not found';
      }
    };

    var expand = function(root, name) {
      var results = [], parts, part;
      // If path is relative
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    };

    var dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };

    this.require = function(name) {
      return require(name, '');
    };

    this.require.define = function(bundle) {
      for (var key in bundle) {
        modules[key] = bundle[key];
      }
    };

    this.require.modules = modules;
    this.require.cache   = cache;
  }

  return this.require;
}).call(this);

var require = this.require;


this.require.define({"animation":function(exports, require, module){(function() {
  var Animation, Animations, Matrix, Tween, dynamics, getFirstFrame, hasCommonProperties, helpers, keysForTransform, parseFrames, stopAnimationsForEl,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Tween = require('tween');

  helpers = require('helpers');

  Matrix = require('matrix');

  dynamics = require('dynamics');

  getFirstFrame = function(properties) {
    var frame, k, style, v, _ref;
    frame = {};
    if (this.el.style != null) {
      style = window.getComputedStyle(this.el, null);
      for (k in properties) {
        if (helpers.transformProperties.contains(k)) {
          k = 'transform';
        }
        if (!frame[k]) {
          v = this.el.style[helpers.support.propertyWithPrefix(k)];
          if (v == null) {
            v = style[helpers.support.propertyWithPrefix(k)];
          }
          frame[k] = v;
        }
      }
    } else {
      _ref = this.el;
      for (k in _ref) {
        v = _ref[k];
        frame[k] = v;
      }
    }
    return frame;
  };

  parseFrames = function(frames) {
    var k, match, newFrames, newProperties, percent, properties, transform, transforms, unit, v, vString, value;
    newFrames = {};
    for (percent in frames) {
      properties = frames[percent];
      transforms = [];
      newProperties = {};
      for (k in properties) {
        v = properties[k];
        if (k === 'transform') {
          transforms.push(v);
        } else if (helpers.transformProperties.contains(k)) {
          v = "" + k + "(" + v + (helpers.unitForProperty(k, v)) + ")";
          transforms.push(v);
        } else {
          vString = v + "";
          match = vString.match(/([-0-9.]*)(.*)/);
          value = parseFloat(match[1]);
          unit = match[2];
          newProperties[k] = {
            value: value,
            originalValue: v,
            unit: unit
          };
        }
      }
      if (transforms.length > 0) {
        transform = transforms.join(' ');
        newProperties['transform'] = {
          value: Matrix.fromTransform(Matrix.transformStringToMatrixString(transform)).decompose(),
          originalValue: transform,
          unit: ''
        };
      }
      newFrames[percent] = newProperties;
    }
    return newFrames;
  };

  keysForTransform = function(transform) {
    var keys, match, matches, _i, _len;
    matches = transform.match(/[a-zA-Z0-9]*\([^)]*\)/g);
    keys = [];
    if (matches != null) {
      for (_i = 0, _len = matches.length; _i < _len; _i++) {
        match = matches[_i];
        keys.push(match.substring(0, match.indexOf('(')));
      }
    }
    return keys;
  };

  Animations = [];

  hasCommonProperties = function(props1, props2) {
    var k, v;
    for (k in props1) {
      v = props1[k];
      if (props2[k] != null) {
        return true;
      }
    }
    return false;
  };

  stopAnimationsForEl = function(el, properties) {
    var animation, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = Animations.length; _i < _len; _i++) {
      animation = Animations[_i];
      if (animation.el === el && hasCommonProperties(animation.to, properties)) {
        _results.push(animation.stop());
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Animation = (function() {
    function Animation(el, to, options) {
      var animation, k, key, pos, redraw, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
      this.el = el;
      this.to = to;
      if (options == null) {
        options = {};
      }
      this.stop = __bind(this.stop, this);
      this.start = __bind(this.start, this);
      this.dynamic = __bind(this.dynamic, this);
      this.setOptions = __bind(this.setOptions, this);
      if (window['jQuery'] && this.el instanceof jQuery) {
        this.el = this.el[0];
      }
      this.animating = false;
      redraw = this.el.offsetHeight;
      this.frames = parseFrames({
        0: getFirstFrame.call(this, this.to),
        100: this.to
      });
      this.keysToInterpolate = [];
      for (k in this.frames[100]) {
        if (k !== 'transform') {
          this.keysToInterpolate.push(k.toLowerCase());
        }
      }
      if (this.frames[100]['transform'] != null) {
        _ref = keysForTransform(this.frames[100]['transform'].originalValue);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          k = _ref[_i];
          this.keysToInterpolate.push(k);
        }
        this.keysToInterpolate = this.keysToInterpolate.map(function(e) {
          return e.toLowerCase();
        });
      }
      for (_j = 0, _len1 = Animations.length; _j < _len1; _j++) {
        animation = Animations[_j];
        if (animation.el !== this.el) {
          continue;
        }
        _ref1 = this.keysToInterpolate;
        for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
          key = _ref1[_k];
          pos = animation.keysToInterpolate.indexOf(key);
          if (pos === -1) {
            continue;
          }
          animation.keysToInterpolate.splice(pos, 1);
        }
      }
      this.setOptions(options);
      if (this.options.debugName && Dynamics.InteractivePanel) {
        Dynamics.InteractivePanel.addAnimation(this);
      }
      Animations.push(this);
    }

    Animation.prototype.setOptions = function(options) {
      var _base, _base1, _base2, _base3;
      if (options == null) {
        options = {};
      }
      this.options = options;
      if ((_base = this.options).duration == null) {
        _base.duration = 1000;
      }
      if ((_base1 = this.options).complete == null) {
        _base1.complete = null;
      }
      if ((_base2 = this.options).type == null) {
        _base2.type = dynamics.Linear;
      }
      if ((_base3 = this.options).animated == null) {
        _base3.animated = true;
      }
      if ((this.options.debugName != null) && (Dynamics.Overrides != null) && Dynamics.Overrides["for"](this.options.debugName)) {
        this.options = Dynamics.Overrides.getOverride(this.options, this.options.debugName);
      }
      this.tween = new Tween(this.options);
      this.tween.animation = this;
      this.dynamic().init();
      return this.returnsToSelf = false || this.dynamic().returnsToSelf;
    };

    Animation.prototype.dynamic = function() {
      return this.tween.dynamic;
    };

    Animation.prototype.start = function(options) {
      if (options == null) {
        options = {};
      }
      if (options.delay == null) {
        options.delay = this.options.delay;
      }
      if (options.delay == null) {
        options.delay = 0;
      }
      stopAnimationsForEl(this.el, this.to);
      if (options.delay <= 0) {
        return this.tween.start();
      } else {
        return setTimeout(this.tween.start.bind(this.tween), options.delay);
      }
    };

    Animation.prototype.stop = function() {
      this.animating = false;
      return this.stopped = true;
    };

    return Animation;

  })();

  module.exports = Animation;

}).call(this);
;}});


this.require.define({"dynamics":function(exports, require, module){(function() {
  var Bezier, Dynamic, EaseInOut, Gravity, GravityWithForce, Linear, SelfSpring, Spring, dynamics,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  dynamics = {};

  Dynamic = (function() {
    Dynamic.properties = {};

    function Dynamic(options) {
      var k, v, _ref;
      this.options = options != null ? options : {};
      this.next = __bind(this.next, this);
      this.init = __bind(this.init, this);
      _ref = this.options.type.properties;
      for (k in _ref) {
        v = _ref[k];
        if ((this.options[k] == null) && !v.editable) {
          this.options[k] = v["default"];
        }
      }
    }

    Dynamic.prototype.init = function() {
      return this.t = 0;
    };

    Dynamic.prototype.next = function(step) {
      var r;
      if (this.t > 1) {
        this.t = 1;
      }
      r = this.at(this.t);
      this.t += step;
      return r;
    };

    Dynamic.prototype.at = function(t) {
      return [t, t];
    };

    return Dynamic;

  })();

  Linear = (function(_super) {
    __extends(Linear, _super);

    function Linear() {
      return Linear.__super__.constructor.apply(this, arguments);
    }

    Linear.properties = {
      duration: {
        min: 100,
        max: 4000,
        "default": 1000
      }
    };

    Linear.prototype.at = function(t) {
      return [t, t];
    };

    return Linear;

  })(Dynamic);

  Gravity = (function(_super) {
    __extends(Gravity, _super);

    Gravity.properties = {
      bounce: {
        min: 0,
        max: 80,
        "default": 40
      },
      gravity: {
        min: 1,
        max: 4000,
        "default": 1000
      },
      expectedDuration: {
        editable: false
      }
    };

    function Gravity(options) {
      this.options = options != null ? options : {};
      this.at = __bind(this.at, this);
      this.curve = __bind(this.curve, this);
      this.init = __bind(this.init, this);
      this.length = __bind(this.length, this);
      this.gravityValue = __bind(this.gravityValue, this);
      this.bounceValue = __bind(this.bounceValue, this);
      this.duration = __bind(this.duration, this);
      this.expectedDuration = __bind(this.expectedDuration, this);
      if (this.initialForce == null) {
        this.initialForce = false;
      }
      this.options.duration = this.duration();
      Gravity.__super__.constructor.call(this, this.options);
    }

    Gravity.prototype.expectedDuration = function() {
      return this.duration();
    };

    Gravity.prototype.duration = function() {
      return Math.round(1000 * 1000 / this.options.gravity * this.length());
    };

    Gravity.prototype.bounceValue = function() {
      return Math.min(this.options.bounce / 100, 80);
    };

    Gravity.prototype.gravityValue = function() {
      return this.options.gravity / 100;
    };

    Gravity.prototype.length = function() {
      var L, b, bounce, curve, gravity;
      bounce = this.bounceValue();
      gravity = this.gravityValue();
      b = Math.sqrt(2 / gravity);
      curve = {
        a: -b,
        b: b,
        H: 1
      };
      if (this.initialForce) {
        curve.a = 0;
        curve.b = curve.b * 2;
      }
      while (curve.H > 0.001) {
        L = curve.b - curve.a;
        curve = {
          a: curve.b,
          b: curve.b + L * bounce,
          H: curve.H * bounce * bounce
        };
      }
      return curve.b;
    };

    Gravity.prototype.init = function() {
      var L, b, bounce, curve, gravity, _results;
      Gravity.__super__.init.apply(this, arguments);
      L = this.length();
      gravity = this.gravityValue() * L * L;
      bounce = this.bounceValue();
      b = Math.sqrt(2 / gravity);
      this.curves = [];
      curve = {
        a: -b,
        b: b,
        H: 1
      };
      if (this.initialForce) {
        curve.a = 0;
        curve.b = curve.b * 2;
      }
      this.curves.push(curve);
      _results = [];
      while (curve.b < 1 && curve.H > 0.001) {
        L = curve.b - curve.a;
        curve = {
          a: curve.b,
          b: curve.b + L * bounce,
          H: curve.H * bounce * bounce
        };
        _results.push(this.curves.push(curve));
      }
      return _results;
    };

    Gravity.prototype.curve = function(a, b, H, t) {
      var L, c, t2;
      L = b - a;
      t2 = (2 / L) * t - 1 - (a * 2 / L);
      c = t2 * t2 * H - H + 1;
      if (this.initialForce) {
        c = 1 - c;
      }
      return c;
    };

    Gravity.prototype.at = function(t) {
      var bounce, curve, gravity, i, v;
      bounce = this.options.bounce / 100;
      gravity = this.options.gravity;
      i = 0;
      curve = this.curves[i];
      while (!(t >= curve.a && t <= curve.b)) {
        i += 1;
        curve = this.curves[i];
        if (!curve) {
          break;
        }
      }
      if (!curve) {
        v = this.initialForce ? 0 : 1;
      } else {
        v = this.curve(curve.a, curve.b, curve.H, t);
      }
      return [t, v];
    };

    return Gravity;

  })(Dynamic);

  GravityWithForce = (function(_super) {
    __extends(GravityWithForce, _super);

    GravityWithForce.prototype.returnsToSelf = true;

    function GravityWithForce(options) {
      this.options = options != null ? options : {};
      this.initialForce = true;
      GravityWithForce.__super__.constructor.call(this, this.options);
    }

    return GravityWithForce;

  })(Gravity);

  Spring = (function(_super) {
    __extends(Spring, _super);

    function Spring() {
      this.at = __bind(this.at, this);
      return Spring.__super__.constructor.apply(this, arguments);
    }

    Spring.properties = {
      frequency: {
        min: 0,
        max: 100,
        "default": 15
      },
      friction: {
        min: 1,
        max: 1000,
        "default": 200
      },
      anticipationStrength: {
        min: 0,
        max: 1000,
        "default": 0
      },
      anticipationSize: {
        min: 0,
        max: 99,
        "default": 0
      },
      duration: {
        min: 100,
        max: 4000,
        "default": 1000
      }
    };

    Spring.prototype.at = function(t) {
      var A, At, a, angle, b, decal, frequency, friction, frictionT, s, v, y0, yS;
      frequency = Math.max(1, this.options.frequency);
      friction = Math.pow(20, this.options.friction / 100);
      s = this.options.anticipationSize / 100;
      decal = Math.max(0, s);
      frictionT = (t / (1 - s)) - (s / (1 - s));
      if (t < s) {
        A = (function(_this) {
          return function(t) {
            var M, a, b, x0, x1;
            M = 0.8;
            x0 = s / (1 - s);
            x1 = 0;
            b = (x0 - (M * x1)) / (x0 - x1);
            a = (M - b) / x0;
            return (a * t * _this.options.anticipationStrength / 100) + b;
          };
        })(this);
        yS = (s / (1 - s)) - (s / (1 - s));
        y0 = (0 / (1 - s)) - (s / (1 - s));
        b = Math.acos(1 / A(yS));
        a = (Math.acos(1 / A(y0)) - b) / (frequency * (-s));
      } else {
        A = (function(_this) {
          return function(t) {
            return Math.pow(friction / 10, -t) * (1 - t);
          };
        })(this);
        b = 0;
        a = 1;
      }
      At = A(frictionT);
      angle = frequency * (t - s) * a + b;
      v = 1 - (At * Math.cos(angle));
      return [t, v, At, frictionT, angle];
    };

    return Spring;

  })(Dynamic);

  SelfSpring = (function(_super) {
    __extends(SelfSpring, _super);

    function SelfSpring() {
      this.at = __bind(this.at, this);
      return SelfSpring.__super__.constructor.apply(this, arguments);
    }

    SelfSpring.properties = {
      frequency: {
        min: 0,
        max: 100,
        "default": 15
      },
      friction: {
        min: 1,
        max: 1000,
        "default": 200
      },
      duration: {
        min: 100,
        max: 4000,
        "default": 1000
      }
    };

    SelfSpring.prototype.returnsToSelf = true;

    SelfSpring.prototype.at = function(t) {
      var A, At, At2, Ax, angle, frequency, friction, v;
      frequency = Math.max(1, this.options.frequency);
      friction = Math.pow(20, this.options.friction / 100);
      A = (function(_this) {
        return function(t) {
          return 1 - Math.pow(friction / 10, -t) * (1 - t);
        };
      })(this);
      At = A(t);
      At2 = A(1 - t);
      Ax = (Math.cos(t * 2 * 3.14 - 3.14) / 2) + 0.5;
      Ax = Math.pow(Ax, this.options.friction / 100);
      angle = frequency * t;
      v = Math.cos(angle) * Ax;
      return [t, v, Ax, -Ax];
    };

    return SelfSpring;

  })(Dynamic);

  Bezier = (function(_super) {
    __extends(Bezier, _super);

    Bezier.properties = {
      points: {
        type: 'points',
        "default": [
          {
            x: 0,
            y: 0,
            controlPoints: [
              {
                x: 0.2,
                y: 0
              }
            ]
          }, {
            x: 0.5,
            y: 1.2,
            controlPoints: [
              {
                x: 0.3,
                y: 1.2
              }, {
                x: 0.8,
                y: 1.2
              }
            ]
          }, {
            x: 1,
            y: 1,
            controlPoints: [
              {
                x: 0.8,
                y: 1
              }
            ]
          }
        ]
      },
      duration: {
        min: 100,
        max: 4000,
        "default": 1000
      }
    };

    function Bezier(options) {
      this.options = options != null ? options : {};
      this.at = __bind(this.at, this);
      this.yForX = __bind(this.yForX, this);
      this.B = __bind(this.B, this);
      this.returnsToSelf = this.options.points[this.options.points.length - 1].y === 0;
      Bezier.__super__.constructor.call(this, this.options);
    }

    Bezier.prototype.B_ = function(t, p0, p1, p2, p3) {
      return (Math.pow(1 - t, 3) * p0) + (3 * Math.pow(1 - t, 2) * t * p1) + (3 * (1 - t) * Math.pow(t, 2) * p2) + Math.pow(t, 3) * p3;
    };

    Bezier.prototype.B = function(t, p0, p1, p2, p3) {
      return {
        x: this.B_(t, p0.x, p1.x, p2.x, p3.x),
        y: this.B_(t, p0.y, p1.y, p2.y, p3.y)
      };
    };

    Bezier.prototype.yForX = function(xTarget, Bs) {
      var B, aB, i, lower, percent, upper, x, xTolerance, _i, _len;
      B = null;
      for (_i = 0, _len = Bs.length; _i < _len; _i++) {
        aB = Bs[_i];
        if (xTarget >= aB(0).x && xTarget <= aB(1).x) {
          B = aB;
        }
        if (B !== null) {
          break;
        }
      }
      if (!B) {
        if (this.returnsToSelf) {
          return 0;
        } else {
          return 1;
        }
      }
      xTolerance = 0.0001;
      lower = 0;
      upper = 1;
      percent = (upper + lower) / 2;
      x = B(percent).x;
      i = 0;
      while (Math.abs(xTarget - x) > xTolerance && i < 100) {
        if (xTarget > x) {
          lower = percent;
        } else {
          upper = percent;
        }
        percent = (upper + lower) / 2;
        x = B(percent).x;
        i += 1;
      }
      return B(percent).y;
    };

    Bezier.prototype.at = function(t) {
      var Bs, i, k, points, x, y, _fn;
      x = t;
      points = this.options.points || Bezier.properties.points["default"];
      Bs = [];
      _fn = (function(_this) {
        return function(pointA, pointB) {
          var B;
          B = function(t) {
            return _this.B(t, pointA, pointA.controlPoints[pointA.controlPoints.length - 1], pointB.controlPoints[0], pointB);
          };
          return Bs.push(B);
        };
      })(this);
      for (i in points) {
        k = parseInt(i);
        if (k >= points.length - 1) {
          break;
        }
        _fn(points[k], points[k + 1]);
      }
      y = this.yForX(x, Bs);
      return [x, y];
    };

    return Bezier;

  })(Dynamic);

  EaseInOut = (function(_super) {
    __extends(EaseInOut, _super);

    EaseInOut.properties = {
      friction: {
        min: 1,
        max: 1000,
        "default": 500
      },
      duration: {
        min: 100,
        max: 4000,
        "default": 1000
      }
    };

    function EaseInOut(options) {
      var friction, points;
      this.options = options != null ? options : {};
      this.at = __bind(this.at, this);
      EaseInOut.__super__.constructor.apply(this, arguments);
      friction = this.options.friction || EaseInOut.properties.friction["default"];
      points = [
        {
          x: 0,
          y: 0,
          controlPoints: [
            {
              x: 1 - (friction / 1000),
              y: 0
            }
          ]
        }, {
          x: 1,
          y: 1,
          controlPoints: [
            {
              x: friction / 1000,
              y: 1
            }
          ]
        }
      ];
      this.bezier = new Bezier({
        type: Bezier,
        duration: this.options.duration,
        points: points
      });
    }

    EaseInOut.prototype.at = function(t) {
      return this.bezier.at(t);
    };

    return EaseInOut;

  })(Dynamic);

  dynamics.Spring = Spring;

  dynamics.SelfSpring = SelfSpring;

  dynamics.Gravity = Gravity;

  dynamics.GravityWithForce = GravityWithForce;

  dynamics.Linear = Linear;

  dynamics.Bezier = Bezier;

  dynamics.EaseInOut = EaseInOut;

  module.exports = dynamics;

}).call(this);
;}});


this.require.define({"element":function(exports, require, module){(function() {
  var Animation, Element, helpers,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Animation = require('animation');

  helpers = require('helpers');

  Element = (function() {
    function Element(el) {
      this.isAnimating = __bind(this.isAnimating, this);
      this.delay = __bind(this.delay, this);
      this.start = __bind(this.start, this);
      this.to = __bind(this.to, this);
      this.css = __bind(this.css, this);
      this.el = __bind(this.el, this);
      this._el = el;
      this._delay = 0;
      this._animations = [];
      this._runningAnimations = 0;
    }

    Element.prototype.el = function() {
      return this._el;
    };

    Element.prototype.css = function(properties) {
      helpers.css(this._el, properties);
      return this;
    };

    Element.prototype.to = function(to, options) {
      var animation, oldComplete;
      if (options == null) {
        options = {};
      }
      animation = new Animation(this._el, to, options);
      options.delay = this._delay;
      oldComplete = options.complete;
      options.complete = (function(_this) {
        return function() {
          _this._runningAnimations -= 1;
          return oldComplete != null ? oldComplete.call(_this, _this, to, animation.options) : void 0;
        };
      })(this);
      this._animations.push(animation);
      return this;
    };

    Element.prototype.start = function() {
      var animation, _i, _len, _ref;
      _ref = this._animations;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        animation = _ref[_i];
        this._runningAnimations += 1;
        animation.start();
      }
      this._animations = [];
      this._delay = 0;
      return this;
    };

    Element.prototype.delay = function(delay) {
      this._delay += delay;
      return this;
    };

    Element.prototype.isAnimating = function() {
      return this._runningAnimations > 0;
    };

    return Element;

  })();

  module.exports = Element;

}).call(this);
;}});


this.require.define({"helpers":function(exports, require, module){(function() {
  var Set, helpers;

  Set = require('set');

  helpers = {};

  helpers.pxProperties = new Set(['marginTop', 'marginLeft', 'marginBottom', 'marginRight', 'paddingTop', 'paddingLeft', 'paddingBottom', 'paddingRight', 'top', 'left', 'bottom', 'right', 'translateX', 'translateY', 'translateZ']);

  helpers.degProperties = new Set(['rotate', 'rotateX', 'rotateY', 'rotateZ', 'skew', 'skewX', 'skewY', 'skewZ']);

  helpers.transformProperties = new Set(['translateX', 'translateY', 'translateZ', 'scale', 'scaleX', 'scaleY', 'scaleZ', 'rotate', 'rotateX', 'rotateY', 'rotateZ', 'skew', 'skewX', 'skewY', 'skewZ', 'perspective', 'width', 'height', 'maxWidth', 'maxHeight', 'minWidth', 'minHeight']);

  helpers.unitForProperty = function(k, v) {
    if (typeof v !== 'number') {
      return '';
    }
    if (helpers.pxProperties.contains(k)) {
      return 'px';
    } else if (helpers.degProperties.contains(k)) {
      return 'deg';
    }
    return '';
  };

  helpers.css = function(el, properties) {
    var k, transforms, v;
    transforms = [];
    for (k in properties) {
      v = properties[k];
      if (k === 'transform') {
        transforms.push(v);
      }
      if (helpers.transformProperties.contains(k)) {
        transforms.push("" + k + "(" + v + (helpers.unitForProperty(k, v)) + ")");
      } else {
        el.style[helpers.support.propertyWithPrefix(k)] = "" + v + (helpers.unitForProperty(k, v));
      }
    }
    if (transforms.length > 0) {
      return el.style[helpers.support.propertyWithPrefix("transform")] = transforms.join(' ');
    }
  };

  helpers.cacheFn = function(func) {
    var cachedMethod, data;
    data = {};
    cachedMethod = function() {
      var k, key, result, _i, _len;
      key = "";
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        k = arguments[_i];
        key += k.toString() + ",";
      }
      result = data[key];
      if (!result) {
        data[key] = result = func.apply(this, arguments);
      }
      return result;
    };
    return cachedMethod;
  };

  helpers.support = {};

  helpers.support.prefixFor = helpers.cacheFn(function(property) {
    var k, prefix, prop, propArray, propertyName, _i, _j, _len, _len1, _ref;
    propArray = property.split('-');
    propertyName = "";
    for (_i = 0, _len = propArray.length; _i < _len; _i++) {
      prop = propArray[_i];
      propertyName += prop.substring(0, 1).toUpperCase() + prop.substring(1);
    }
    _ref = ["Webkit", "Moz"];
    for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
      prefix = _ref[_j];
      k = prefix + propertyName;
      if (document.body.style[k] !== void 0) {
        return prefix;
      }
    }
    return '';
  });

  helpers.support.propertyWithPrefix = helpers.cacheFn(function(property) {
    var prefix;
    prefix = helpers.support.prefixFor(property);
    if (prefix === 'Moz') {
      return "" + prefix + (property.substring(0, 1).toUpperCase() + property.substring(1));
    }
    if (prefix !== '') {
      return "-" + (prefix.toLowerCase()) + "-" + property;
    }
    return property;
  });

  module.exports = helpers;

}).call(this);
;}});


this.require.define({"loop":function(exports, require, module){(function() {
  var Loop, Matrix, defaultForProperty, helpers, propertiesAtFrame;

  Matrix = require('matrix');

  helpers = require('helpers');

  defaultForProperty = function(property) {
    if (property === 'opacity') {
      return 1;
    }
    return 0;
  };

  propertiesAtFrame = function(t, args) {
    var dValue, frame0, frame1, k, newValue, oldValue, progress, properties, transform, unit, v, value;
    if (args == null) {
      args = {};
    }
    frame0 = this.frames[0];
    frame1 = this.frames[100];
    progress = args.progress;
    if (progress == null) {
      progress = -1;
    }
    transform = '';
    properties = {};
    for (k in frame1) {
      v = frame1[k];
      value = v.value;
      unit = v.unit;
      newValue = null;
      if (progress >= 1) {
        if (this.returnsToSelf) {
          newValue = frame0[k].value;
        } else {
          newValue = frame1[k].value;
        }
      }
      if (k === 'transform') {
        if (this.keysToInterpolate.length === 0) {
          continue;
        }
        if (newValue == null) {
          newValue = Matrix.interpolate(frame0[k].value, frame1[k].value, t, this.keysToInterpolate);
        }
        properties['transform'] = Matrix.recompose(newValue);
      } else if (this.keysToInterpolate.indexOf(k.toLowerCase()) !== -1) {
        if (!newValue) {
          oldValue = null;
          if (frame0[k]) {
            oldValue = frame0[k].value;
          }
          if ((oldValue == null) || isNaN(oldValue)) {
            oldValue = defaultForProperty(k);
          }
          dValue = value - oldValue;
          newValue = oldValue + (dValue * t);
        }
        properties[k] = newValue;
      }
    }
    return properties;
  };

  Loop = {
    tweens: [],
    tweensToRemoveAtNextTick: [],
    running: false,
    start: function() {
      this.running = true;
      return requestAnimationFrame(this.tick.bind(this));
    },
    stop: function() {
      return this.running = false;
    },
    tick: function(ts) {
      var animation, el, elProperties, found, k, properties, propertiesByEls, tween, tweens, v, _base, _base1, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1;
      if (!this.running) {
        return;
      }
      tweens = this.tweens.slice();
      propertiesByEls = [];
      for (_i = 0, _len = tweens.length; _i < _len; _i++) {
        tween = tweens[_i];
        tween.tick(ts);
      }
      for (_j = 0, _len1 = tweens.length; _j < _len1; _j++) {
        tween = tweens[_j];
        if (tween.animation == null) {
          continue;
        }
        animation = tween.animation;
        properties = propertiesAtFrame.call(animation, tween.value, {
          progress: tween.t
        });
        found = false;
        for (_k = 0, _len2 = propertiesByEls.length; _k < _len2; _k++) {
          _ref = propertiesByEls[_k], el = _ref[0], elProperties = _ref[1];
          if (animation.el === el) {
            for (k in properties) {
              v = properties[k];
              if (k === 'transform' && elProperties[k]) {
                v = v.multiply(elProperties[k]);
              }
              elProperties[k] = v;
            }
            found = true;
            break;
          }
        }
        if (!found) {
          propertiesByEls.push([animation.el, properties]);
        }
      }
      for (_l = 0, _len3 = propertiesByEls.length; _l < _len3; _l++) {
        _ref1 = propertiesByEls[_l], el = _ref1[0], properties = _ref1[1];
        if (properties['transform'] != null) {
          properties['transform'] = properties['transform'].toString();
        }
        if (el.style) {
          helpers.css(el, properties);
        } else {
          for (k in properties) {
            v = properties[k];
            el[k] = v;
          }
        }
      }
      for (_m = 0, _len4 = tweens.length; _m < _len4; _m++) {
        tween = tweens[_m];
        if (typeof (_base = tween.options).change === "function") {
          _base.change(tween.t, tween.value);
        }
        if (tween.t === 1) {
          if (typeof (_base1 = tween.options).complete === "function") {
            _base1.complete();
          }
        }
      }
      this.removeUselessTweens();
      return requestAnimationFrame(this.tick.bind(this));
    },
    add: function(tween) {
      if (this.tweens.indexOf(tween) === -1) {
        this.tweens.push(tween);
      }
      if (!this.running && this.tweens.length > 0) {
        return this.start();
      }
    },
    remove: function(tween) {
      return this.tweensToRemoveAtNextTick.push(tween);
    },
    removeUselessTweens: function() {
      var tween, _i, _len, _ref;
      _ref = this.tweensToRemoveAtNextTick;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tween = _ref[_i];
        this.tweens.splice(this.tweens.indexOf(tween), 1);
      }
      this.tweensToRemoveAtNextTick = [];
      if (this.running && this.tweens.length === 0) {
        return this.stop();
      }
    }
  };

  module.exports = Loop;

}).call(this);
;}});


this.require.define({"matrix":function(exports, require, module){(function() {
  var Matrix, Vector, helpers,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Vector = require('vector');

  helpers = require('helpers');

  Matrix = (function() {
    function Matrix(els) {
      this.els = els;
      this.toString = __bind(this.toString, this);
      this.decompose = __bind(this.decompose, this);
      this.inverse = __bind(this.inverse, this);
      this.augment = __bind(this.augment, this);
      this.toRightTriangular = __bind(this.toRightTriangular, this);
      this.transpose = __bind(this.transpose, this);
      this.multiply = __bind(this.multiply, this);
      this.dup = __bind(this.dup, this);
      this.e = __bind(this.e, this);
    }

    Matrix.prototype.e = function(i, j) {
      if (i < 1 || i > this.els.length || j < 1 || j > this.els[0].length) {
        return null;
      }
      return this.els[i - 1][j - 1];
    };

    Matrix.prototype.dup = function() {
      return new Matrix(this.els);
    };

    Matrix.prototype.multiply = function(matrix) {
      var M, c, cols, elements, i, j, ki, kj, nc, ni, nj, returnVector, sum;
      returnVector = matrix.modulus ? true : false;
      M = matrix.els || matrix;
      if (typeof M[0][0] === 'undefined') {
        M = new Matrix(M).els;
      }
      ni = this.els.length;
      ki = ni;
      kj = M[0].length;
      cols = this.els[0].length;
      elements = [];
      ni += 1;
      while (--ni) {
        i = ki - ni;
        elements[i] = [];
        nj = kj;
        nj += 1;
        while (--nj) {
          j = kj - nj;
          sum = 0;
          nc = cols;
          nc += 1;
          while (--nc) {
            c = cols - nc;
            sum += this.els[i][c] * M[c][j];
          }
          elements[i][j] = sum;
        }
      }
      M = new Matrix(elements);
      if (returnVector) {
        return M.col(1);
      } else {
        return M;
      }
    };

    Matrix.prototype.transpose = function() {
      var cols, elements, i, j, ni, nj, rows;
      rows = this.els.length;
      cols = this.els[0].length;
      elements = [];
      ni = cols;
      ni += 1;
      while (--ni) {
        i = cols - ni;
        elements[i] = [];
        nj = rows;
        nj += 1;
        while (--nj) {
          j = rows - nj;
          elements[i][j] = this.els[j][i];
        }
      }
      return new Matrix(elements);
    };

    Matrix.prototype.toRightTriangular = function() {
      var M, els, i, j, k, kp, multiplier, n, np, p, _i, _j, _ref, _ref1;
      M = this.dup();
      n = this.els.length;
      k = n;
      kp = this.els[0].length;
      while (--n) {
        i = k - n;
        if (M.els[i][i] === 0) {
          for (j = _i = _ref = i + 1; _ref <= k ? _i < k : _i > k; j = _ref <= k ? ++_i : --_i) {
            if (M.els[j][i] !== 0) {
              els = [];
              np = kp;
              np += 1;
              while (--np) {
                p = kp - np;
                els.push(M.els[i][p] + M.els[j][p]);
              }
              M.els[i] = els;
              break;
            }
          }
        }
        if (M.els[i][i] !== 0) {
          for (j = _j = _ref1 = i + 1; _ref1 <= k ? _j < k : _j > k; j = _ref1 <= k ? ++_j : --_j) {
            multiplier = M.els[j][i] / M.els[i][i];
            els = [];
            np = kp;
            np += 1;
            while (--np) {
              p = kp - np;
              els.push(p <= i ? 0 : M.els[j][p] - M.els[i][p] * multiplier);
            }
            M.els[j] = els;
          }
        }
      }
      return M;
    };

    Matrix.prototype.augment = function(matrix) {
      var M, T, cols, i, j, ki, kj, ni, nj;
      M = matrix.els || matrix;
      if (typeof M[0][0] === 'undefined') {
        M = new Matrix(M).els;
      }
      T = this.dup();
      cols = T.els[0].length;
      ni = T.els.length;
      ki = ni;
      kj = M[0].length;
      if (ni !== M.length) {
        return null;
      }
      ni += 1;
      while (--ni) {
        i = ki - ni;
        nj = kj;
        nj += 1;
        while (--nj) {
          j = kj - nj;
          T.els[i][cols + j] = M[i][j];
        }
      }
      return T;
    };

    Matrix.prototype.inverse = function() {
      var M, divisor, els, i, inverse_elements, j, ki, kp, new_element, np, p, vni, _i;
      vni = this.els.length;
      ki = ni;
      M = this.augment(Matrix.I(ni)).toRightTriangular();
      kp = M.els[0].length;
      inverse_elements = [];
      ni += 1;
      while (--ni) {
        i = ni - 1;
        els = [];
        np = kp;
        inverse_elements[i] = [];
        divisor = M.els[i][i];
        np += 1;
        while (--np) {
          p = kp - np;
          new_element = M.els[i][p] / divisor;
          els.push(new_element);
          if (p >= ki) {
            inverse_elements[i].push(new_element);
          }
        }
        M.els[i] = els;
        for (j = _i = 0; 0 <= i ? _i < i : _i > i; j = 0 <= i ? ++_i : --_i) {
          els = [];
          np = kp;
          np += 1;
          while (--np) {
            p = kp - np;
            els.push(M.els[j][p] - M.els[i][p] * M.els[j][i]);
          }
          M.els[j] = els;
        }
      }
      return new Matrix(inverse_elements);
    };

    Matrix.I = function(n) {
      var els, i, j, k, nj;
      els = [];
      k = n;
      n += 1;
      while (--n) {
        i = k - n;
        els[i] = [];
        nj = k;
        nj += 1;
        while (--nj) {
          j = k - nj;
          els[i][j] = i === j ? 1 : 0;
        }
      }
      return new Matrix(els);
    };

    Matrix.prototype.decompose = function() {
      var els, i, inversePerspectiveMatrix, j, k, matrix, pdum3, perspective, perspectiveMatrix, quaternion, result, rightHandSide, rotate, row, rowElement, s, scale, skew, t, translate, transposedInversePerspectiveMatrix, type, typeKey, v, w, x, y, z, _i, _j, _k, _l, _m, _n, _o, _p;
      matrix = this;
      translate = [];
      scale = [];
      skew = [];
      quaternion = [];
      perspective = [];
      els = matrix.els;
      if (els[3][3] === 0) {
        return false;
      }
      for (i = _i = 0; _i <= 3; i = ++_i) {
        for (j = _j = 0; _j <= 3; j = ++_j) {
          els[i][j] /= els[3][3];
        }
      }
      perspectiveMatrix = matrix.dup();
      for (i = _k = 0; _k <= 2; i = ++_k) {
        perspectiveMatrix.els[i][3] = 0;
      }
      perspectiveMatrix.els[3][3] = 1;
      if (els[0][3] !== 0 || els[1][3] !== 0 || els[2][3] !== 0) {
        rightHandSide = new Vector(els.slice(0, 4)[3]);
        inversePerspectiveMatrix = perspectiveMatrix.inverse();
        transposedInversePerspectiveMatrix = inversePerspectiveMatrix.transpose();
        perspective = transposedInversePerspectiveMatrix.multiply(rightHandSide).els;
        for (i = _l = 0; _l <= 2; i = ++_l) {
          els[i][3] = 0;
        }
        els[3][3] = 1;
      } else {
        perspective = [0, 0, 0, 1];
      }
      for (i = _m = 0; _m <= 2; i = ++_m) {
        translate[i] = els[3][i];
        els[3][i] = 0;
      }
      row = [];
      for (i = _n = 0; _n <= 2; i = ++_n) {
        row[i] = new Vector(els[i].slice(0, 3));
      }
      scale[0] = row[0].length();
      row[0] = row[0].normalize();
      skew[0] = row[0].dot(row[1]);
      row[1] = row[1].combine(row[0], 1.0, -skew[0]);
      scale[1] = row[1].length();
      row[1] = row[1].normalize();
      skew[0] /= scale[1];
      skew[1] = row[0].dot(row[2]);
      row[2] = row[2].combine(row[0], 1.0, -skew[1]);
      skew[2] = row[1].dot(row[2]);
      row[2] = row[2].combine(row[1], 1.0, -skew[2]);
      scale[2] = row[2].length();
      row[2] = row[2].normalize();
      skew[1] /= scale[2];
      skew[2] /= scale[2];
      pdum3 = row[1].cross(row[2]);
      if (row[0].dot(pdum3) < 0) {
        for (i = _o = 0; _o <= 2; i = ++_o) {
          scale[i] *= -1;
          for (j = _p = 0; _p <= 2; j = ++_p) {
            row[i].els[j] *= -1;
          }
        }
      }
      rowElement = function(index, elementIndex) {
        return row[index].els[elementIndex];
      };
      rotate = [];
      rotate[1] = Math.asin(-rowElement(0, 2));
      if (Math.cos(rotate[1]) !== 0) {
        rotate[0] = Math.atan2(rowElement(1, 2), rowElement(2, 2));
        rotate[2] = Math.atan2(rowElement(0, 1), rowElement(0, 0));
      } else {
        rotate[0] = Math.atan2(-rowElement(2, 0), rowElement(1, 1));
        rotate[1] = 0;
      }
      t = rowElement(0, 0) + rowElement(1, 1) + rowElement(2, 2) + 1.0;
      if (t > 1e-4) {
        s = 0.5 / Math.sqrt(t);
        w = 0.25 / s;
        x = (rowElement(2, 1) - rowElement(1, 2)) * s;
        y = (rowElement(0, 2) - rowElement(2, 0)) * s;
        z = (rowElement(1, 0) - rowElement(0, 1)) * s;
      } else if ((rowElement(0, 0) > rowElement(1, 1)) && (rowElement(0, 0) > rowElement(2, 2))) {
        s = Math.sqrt(1.0 + rowElement(0, 0) - rowElement(1, 1) - rowElement(2, 2)) * 2.0;
        x = 0.25 * s;
        y = (rowElement(0, 1) + rowElement(1, 0)) / s;
        z = (rowElement(0, 2) + rowElement(2, 0)) / s;
        w = (rowElement(2, 1) - rowElement(1, 2)) / s;
      } else if (rowElement(1, 1) > rowElement(2, 2)) {
        s = Math.sqrt(1.0 + rowElement(1, 1) - rowElement(0, 0) - rowElement(2, 2)) * 2.0;
        x = (rowElement(0, 1) + rowElement(1, 0)) / s;
        y = 0.25 * s;
        z = (rowElement(1, 2) + rowElement(2, 1)) / s;
        w = (rowElement(0, 2) - rowElement(2, 0)) / s;
      } else {
        s = Math.sqrt(1.0 + rowElement(2, 2) - rowElement(0, 0) - rowElement(1, 1)) * 2.0;
        x = (rowElement(0, 2) + rowElement(2, 0)) / s;
        y = (rowElement(1, 2) + rowElement(2, 1)) / s;
        z = 0.25 * s;
        w = (rowElement(1, 0) - rowElement(0, 1)) / s;
      }
      quaternion = [x, y, z, w];
      result = {
        translate: translate,
        scale: scale,
        skew: skew,
        quaternion: quaternion,
        perspective: perspective,
        rotate: rotate
      };
      for (typeKey in result) {
        type = result[typeKey];
        for (k in type) {
          v = type[k];
          if (isNaN(v)) {
            type[k] = 0;
          }
        }
      }
      return result;
    };

    Matrix.interpolate = function(decomposedA, decomposedB, t, only) {
      var angle, decomposed, i, invscale, invth, k, qa, qb, scale, th, _i, _j, _k, _l, _len, _ref, _ref1;
      if (only == null) {
        only = [];
      }
      decomposed = {};
      _ref = ['translate', 'scale', 'skew', 'perspective'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        k = _ref[_i];
        decomposed[k] = [];
        for (i = _j = 0, _ref1 = decomposedA[k].length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          if (only.indexOf(k) > -1 || only.indexOf("" + k + ['x', 'y', 'z'][i]) > -1) {
            decomposed[k][i] = (decomposedB[k][i] - decomposedA[k][i]) * t + decomposedA[k][i];
          } else {
            decomposed[k][i] = decomposedA[k][i];
          }
        }
      }
      if (only.indexOf('rotate') !== -1) {
        qa = decomposedA.quaternion;
        qb = decomposedB.quaternion;
        angle = qa[0] * qb[0] + qa[1] * qb[1] + qa[2] * qb[2] + qa[3] * qb[3];
        if (angle < 0.0) {
          for (i = _k = 0; _k <= 3; i = ++_k) {
            qa[i] = -qa[i];
          }
          angle = -angle;
        }
        if (angle + 1.0 > .05) {
          if (1.0 - angle >= .05) {
            th = Math.acos(angle);
            invth = 1.0 / Math.sin(th);
            scale = Math.sin(th * (1.0 - t)) * invth;
            invscale = Math.sin(th * t) * invth;
          } else {
            scale = 1.0 - t;
            invscale = t;
          }
        } else {
          qb[0] = -qa[1];
          qb[1] = qa[0];
          qb[2] = -qa[3];
          qb[3] = qa[2];
          scale = Math.sin(piDouble * (.5 - t));
          invscale = Math.sin(piDouble * t);
        }
        decomposed.quaternion = [];
        for (i = _l = 0; _l <= 3; i = ++_l) {
          decomposed.quaternion[i] = qa[i] * scale + qb[i] * invscale;
        }
      } else {
        decomposed.quaternion = decomposedA.quaternion;
      }
      return decomposed;
    };

    Matrix.recompose = function(decomposedMatrix) {
      var i, j, match, matrix, quaternion, skew, temp, w, x, y, z, _i, _j, _k, _l;
      matrix = Matrix.I(4);
      for (i = _i = 0; _i <= 3; i = ++_i) {
        matrix.els[i][3] = decomposedMatrix.perspective[i];
      }
      quaternion = decomposedMatrix.quaternion;
      x = quaternion[0];
      y = quaternion[1];
      z = quaternion[2];
      w = quaternion[3];
      skew = decomposedMatrix.skew;
      match = [[1, 0], [2, 0], [2, 1]];
      for (i = _j = 2; _j >= 0; i = --_j) {
        if (skew[i]) {
          temp = Matrix.I(4);
          temp.els[match[i][0]][match[i][1]] = skew[i];
          matrix = matrix.multiply(temp);
        }
      }
      matrix = matrix.multiply(new Matrix([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w), 0], [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w), 0], [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y), 0], [0, 0, 0, 1]]));
      for (i = _k = 0; _k <= 2; i = ++_k) {
        for (j = _l = 0; _l <= 2; j = ++_l) {
          matrix.els[i][j] *= decomposedMatrix.scale[i];
        }
        matrix.els[3][i] = decomposedMatrix.translate[i];
      }
      return matrix;
    };

    Matrix.prototype.toString = function() {
      var i, j, str, _i, _j;
      str = 'matrix3d(';
      for (i = _i = 0; _i <= 3; i = ++_i) {
        for (j = _j = 0; _j <= 3; j = ++_j) {
          str += this.els[i][j];
          if (!(i === 3 && j === 3)) {
            str += ',';
          }
        }
      }
      str += ')';
      return str;
    };

    Matrix.transformStringToMatrixString = helpers.cacheFn(function(transform) {
      var matrixEl, result, style;
      matrixEl = document.createElement('div');
      matrixEl.style[helpers.support.propertyWithPrefix("transform")] = transform;
      document.body.appendChild(matrixEl);
      style = window.getComputedStyle(matrixEl, null);
      result = style.transform || style[helpers.support.propertyWithPrefix("transform")];
      document.body.removeChild(matrixEl);
      return result;
    });

    Matrix.fromTransform = function(transform) {
      var digits, elements, i, match, matrixElements, _i;
      match = transform.match(/matrix3?d?\(([-0-9, \.]*)\)/);
      if (match) {
        digits = match[1].split(',');
        digits = digits.map(parseFloat);
        if (digits.length === 6) {
          elements = [digits[0], digits[1], 0, 0, digits[2], digits[3], 0, 0, 0, 0, 1, 0, digits[4], digits[5], 0, 1];
        } else {
          elements = digits;
        }
      } else {
        elements = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
      }
      matrixElements = [];
      for (i = _i = 0; _i <= 3; i = ++_i) {
        matrixElements.push(elements.slice(i * 4, i * 4 + 4));
      }
      return new Matrix(matrixElements);
    };

    return Matrix;

  })();

  module.exports = Matrix;

}).call(this);
;}});


this.require.define({"set":function(exports, require, module){(function() {
  var Set;

  Set = (function() {
    function Set(array) {
      var v, _i, _len;
      this.obj = {};
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        v = array[_i];
        this.obj[v] = 1;
      }
    }

    Set.prototype.contains = function(v) {
      return this.obj[v] === 1;
    };

    return Set;

  })();

  module.exports = Set;

}).call(this);
;}});


this.require.define({"tween":function(exports, require, module){(function() {
  var Loop, Tween,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Loop = require('loop');

  Tween = (function() {
    function Tween(options) {
      this.options = options;
      this.tick = __bind(this.tick, this);
      this.stop = __bind(this.stop, this);
      this.start = __bind(this.start, this);
      this.dynamic = new this.options.type(this.options);
    }

    Tween.prototype.start = function() {
      this.animating = true;
      this.stopped = false;
      this.ts = null;
      return Loop.add(this);
    };

    Tween.prototype.stop = function() {
      this.animating = false;
      this.stopped = true;
      return Loop.remove(this);
    };

    Tween.prototype.tick = function(ts) {
      var dTs;
      if (this.stopped) {
        Loop.remove(this);
        return;
      }
      this.t = 0;
      if (this.ts) {
        dTs = ts - this.ts;
        this.t = dTs / this.options.duration;
      } else {
        this.ts = ts;
      }
      if (this.t > 1) {
        this.t = 1;
      }
      this.value = this.dynamic.at(this.t)[1];
      if (this.t === 1) {
        Loop.remove(this);
        this.stopped = true;
        return this.animating = false;
      }
    };

    return Tween;

  })();

  module.exports = Tween;

}).call(this);
;}});


this.require.define({"vector":function(exports, require, module){(function() {
  var Vector,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Vector = (function() {
    function Vector(els) {
      this.els = els;
      this.combine = __bind(this.combine, this);
      this.normalize = __bind(this.normalize, this);
      this.length = __bind(this.length, this);
      this.cross = __bind(this.cross, this);
      this.dot = __bind(this.dot, this);
      this.e = __bind(this.e, this);
    }

    Vector.prototype.e = function(i) {
      if (i < 1 || i > this.els.length) {
        return null;
      } else {
        return this.els[i - 1];
      }
    };

    Vector.prototype.dot = function(vector) {
      var V, n, product;
      V = vector.els || vector;
      product = 0;
      n = this.els.length;
      if (n !== V.length) {
        return null;
      }
      n += 1;
      while (--n) {
        product += this.els[n - 1] * V[n - 1];
      }
      return product;
    };

    Vector.prototype.cross = function(vector) {
      var A, B;
      B = vector.els || vector;
      if (this.els.length !== 3 || B.length !== 3) {
        return null;
      }
      A = this.els;
      return new Vector([(A[1] * B[2]) - (A[2] * B[1]), (A[2] * B[0]) - (A[0] * B[2]), (A[0] * B[1]) - (A[1] * B[0])]);
    };

    Vector.prototype.length = function() {
      var a, e, _i, _len, _ref;
      a = 0;
      _ref = this.els;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        a += Math.pow(e, 2);
      }
      return Math.sqrt(a);
    };

    Vector.prototype.normalize = function() {
      var e, i, length, newElements, _ref;
      length = this.length();
      newElements = [];
      _ref = this.els;
      for (i in _ref) {
        e = _ref[i];
        newElements[i] = e / length;
      }
      return new Vector(newElements);
    };

    Vector.prototype.combine = function(b, ascl, bscl) {
      var i, result, _i;
      result = [];
      for (i = _i = 0; _i <= 2; i = ++_i) {
        result[i] = (ascl * this.els[i]) + (bscl * b.els[i]);
      }
      return new Vector(result);
    };

    return Vector;

  })();

  module.exports = Vector;

}).call(this);
;}});


(function() {
  var Element, ElementStore, dynamic, dynamics, k, v;

  Element = require('element');

  dynamics = require('dynamics');

  ElementStore = {
    dynamicElements: [],
    dynamicElementFor: function(el) {
      var dynamicElement, _i, _len, _ref;
      _ref = this.dynamicElements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dynamicElement = _ref[_i];
        if (dynamicElement.el() === el) {
          return dynamicElement;
        }
      }
      dynamicElement = new Element(el);
      this.dynamicElements.push(dynamicElement);
      return dynamicElement;
    }
  };

  dynamic = function(el) {
    return ElementStore.dynamicElementFor(el);
  };

  for (k in dynamics) {
    v = dynamics[k];
    dynamic[k] = v;
  }

  this.dynamic = dynamic;

}).call(this);

  return this.dynamic;
}.apply({});