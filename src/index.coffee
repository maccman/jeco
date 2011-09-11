CoffeeScript = require "coffee-script"
{preprocess} = require "eco/lib/preprocessor"
{indent}     = require "eco/lib/util"

exports.precompile = precompile = (source) ->
  script = CoffeeScript.compile preprocess(source), noWrap: true

  """
    function(__obj) {
      if (!__obj) __obj = {};
      var $ = jQuery.sub();
      $.push = function(element){ 
        return $ = $.add(element); 
      };
      var __out = jQuery(), __capture = function(callback) {
        var out = __out, result;
        __out = jQuery();
        callback.call(this);
        result = __out;
        __out = out;
        return result;
      },  __sanitize = function(html){ 
        return html; 
      }, item = function(obj, template) {
        if (!template) template = obj, obj = __obj;
        return $(template).data('eco', obj);
      };
      if (!__escape) {
        __escape = __obj.escape = function(value) {
          return ('' + value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/\x22/g, '&quot;');
        };
      }
      (function() {
    #{indent script, 4}
      }).call(__obj);
      __obj.safe = __objSafe, __obj.escape = __escape;
      return item(__out);
    }
  """

exports.compile = compile = (source) ->
  do new Function "return #{precompile source}"
  
if require.extensions
  require.extensions[".jeco"] = (module, filename) ->
    source = require("fs").readFileSync filename, "utf-8"
    module._compile "module.exports = #{precompile source}", filename