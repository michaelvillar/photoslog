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
this.require.define({ "controller" : function(exports, require, module) {var Controller, EventDispatcher,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventDispatcher = require('eventDispatcher');

Controller = (function(_super) {
  __extends(Controller, _super);

  function Controller(options) {
    if (options == null) {
      options = {};
    }
    Controller.__super__.constructor.apply(this, arguments);
    this.options = options;
    this.view = null;
  }

  return Controller;

})(EventDispatcher);

module.exports = Controller;}});this.require.define({ "eventDispatcher" : function(exports, require, module) {var EventDispatcher, Module,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

Module = require('module');

EventDispatcher = (function(_super) {
  __extends(EventDispatcher, _super);

  function EventDispatcher() {
    this.triggerToSubviews = __bind(this.triggerToSubviews, this);
    this.trigger = __bind(this.trigger, this);
    this.off = __bind(this.off, this);
    this.on = __bind(this.on, this);
    this.eventCallbacks = {};
  }

  EventDispatcher.prototype.on = function(eventName, callback) {
    var _base;
    (_base = this.eventCallbacks)[eventName] || (_base[eventName] = []);
    return this.eventCallbacks[eventName].push(callback);
  };

  EventDispatcher.prototype.off = function(eventName, callback) {
    if (eventName == null) {
      eventName = null;
    }
    if (callback == null) {
      callback = null;
    }
    if (!eventName) {
      return this.eventCallbacks = {};
    } else if (!callback) {
      return this.eventCallbacks[eventName] = [];
    } else {
      return this.eventCallbacks[eventName] = this.eventCallbacks[eventName].map(function(cb) {
        if (cb !== callback) {
          return cb;
        }
      });
    }
  };

  EventDispatcher.prototype.trigger = function() {
    var args, callback, callbacks, eventName, _i, _len, _results;
    eventName = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    tracker.trace.trigger(eventName, args);
    callbacks = this.eventCallbacks[eventName];
    if (callbacks == null) {
      return;
    }
    callbacks = callbacks.slice();
    _results = [];
    for (_i = 0, _len = callbacks.length; _i < _len; _i++) {
      callback = callbacks[_i];
      _results.push(callback.apply(null, args));
    }
    return _results;
  };

  EventDispatcher.prototype.triggerToSubviews = function() {
    var args, eventName, subview, _i, _len, _ref, _results;
    eventName = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    this.trigger.apply(this, arguments);
    if (this.subviews != null) {
      _ref = this.subviews;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        subview = _ref[_i];
        _results.push(subview.triggerToSubviews.apply(subview, arguments));
      }
      return _results;
    }
  };

  EventDispatcher.prototype.propagateEvent = function(event, source) {
    return source.on(event, (function(_this) {
      return function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return _this.trigger.apply(_this, [event].concat(__slice.call(args)));
      };
    })(this));
  };

  return EventDispatcher;

})(Module);

module.exports = EventDispatcher;}});this.require.define({ "module" : function(exports, require, module) {var Module, moduleKeywords,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

moduleKeywords = ['extended', 'included'];

Module = (function() {
  function Module() {}

  Module.extend = function(obj) {
    var func, name, _ref;
    for (name in obj) {
      func = obj[name];
      if (__indexOf.call(moduleKeywords, name) < 0) {
        this[name] = func;
      }
    }
    if ((_ref = obj.extended) != null) {
      _ref.apply(this);
    }
    return this;
  };

  Module.include = function(obj) {
    var func, name, _ref;
    for (name in obj) {
      func = obj[name];
      if (__indexOf.call(moduleKeywords, name) < 0) {
        this.prototype[name] = func;
      }
    }
    if ((_ref = obj.included) != null) {
      _ref.apply(this);
    }
    return this;
  };

  return Module;

})();

module.exports = Module;}});this.require.define({ "view" : function(exports, require, module) {var EventDispatcher, View,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventDispatcher = require('eventDispatcher');

View = (function(_super) {
  __extends(View, _super);

  View.prototype.tag = 'div';

  function View(options) {
    var className;
    this.options = options != null ? options : {};
    this.addSubviews = __bind(this.addSubviews, this);
    this.addSubview = __bind(this.addSubview, this);
    View.__super__.constructor.apply(this, arguments);
    this.el = this.el || this.options.el || document.createElement(this.options['tag'] || this.tag);
    className = this.className || this.options.className;
    if (className != null) {
      this.el.classList.add(className);
    }
    this.subviews = [];
  }

  View.prototype.addSubview = function(subview) {
    this.el.appendChild(subview.el);
    return this.subviews.push(subview);
  };

  View.prototype.addSubviews = function(subviews) {
    var subview, _i, _len, _results;
    if (subviews == null) {
      subviews = [];
    }
    _results = [];
    for (_i = 0, _len = subviews.length; _i < _len; _i++) {
      subview = subviews[_i];
      _results.push(this.addSubview(subview));
    }
    return _results;
  };

  return View;

})(EventDispatcher);

module.exports = View;}});this.require.define({ "app" : function(exports, require, module) {var App, Controller, View,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Controller = require('controller');

View = require('view');

App = (function(_super) {
  __extends(App, _super);

  function App() {
    App.__super__.constructor.apply(this, arguments);
    this.view = new View({
      el: document.body
    });
  }

  return App;

})(Controller);

module.exports = App;}});
;
