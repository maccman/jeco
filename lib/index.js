(function() {
  var CoffeeScript, compile, indent, precompile, preprocess;
  CoffeeScript = require("coffee-script");
  preprocess = require("eco/lib/preprocessor").preprocess;
  indent = require("eco/lib/util").indent;
  exports.precompile = precompile = function(source) {
    var script;
    script = CoffeeScript.compile(preprocess(source), {
      noWrap: true
    });
    return "function(__obj) {\n  if (!__obj) __obj = {};\n  var $ = jQuery.sub();\n  $.push = function(element){ \n    return $ = $.add(element); \n  };\n  var __out = jQuery(), __capture = function(callback) {\n    var out = __out, result;\n    __out = jQuery();\n    callback.call(this);\n    result = __out;\n    __out = out;\n    return result;\n  },  __sanitize = function(html){ \n    return html; \n  }, item = function(obj, template) {\n    if (!template) template = obj, obj = __obj;\n    return $(template).data('eco', obj);\n  };\n  if (!__escape) {\n    __escape = __obj.escape = function(value) {\n      return ('' + value)\n        .replace(/&/g, '&amp;')\n        .replace(/</g, '&lt;')\n        .replace(/>/g, '&gt;')\n        .replace(/\x22/g, '&quot;');\n    };\n  }\n  (function() {\n" + (indent(script, 4)) + "\n  }).call(__obj);\n  __obj.safe = __objSafe, __obj.escape = __escape;\n  return item(__out);\n}";
  };
  exports.compile = compile = function(source) {
    return new Function("return " + (precompile(source)))();
  };
  if (require.extensions) {
    require.extensions[".jeco"] = function(module, filename) {
      var source;
      source = require("fs").readFileSync(filename, "utf-8");
      return module._compile("module.exports = " + (precompile(source)), filename);
    };
  }
}).call(this);
