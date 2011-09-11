CoffeeScript = require "coffee-script"
{preprocess} = require "eco/lib/preprocessor"
{indent}     = require "eco/lib/util"

exports.precompile = precompile = (source) ->
  script = CoffeeScript.compile preprocess(source), noWrap: true

  """
    function(__obj) {
      if (!__obj) __obj = {};
      var $ = jQuery.sub();
      $.fn.push = function(selector){ 
        var set = typeof selector === "string" ?
    				$( selector, context ) :
    				$.makeArray( selector && selector.nodeType ? [ selector ] : selector )
    	  $.merge( this, set );
    	  return this;
      };
      var __out = jQuery(), __capture = function(callback) {
        var out = __out, result;
        __out = jQuery();
        callback.call(this);
        result = __out;
        __out = out;
        return result;
      }, item = function(obj, template) {
        if (!template) template = obj, obj = __obj;
        return $(template).data('eco', obj);
      }, __sanitize = function(value) {
        if (value && value.ecoSafe) {
          return value;
        } else if (typeof value !== 'undefined' && value != null) {
          return __escape(value);
        } else {
          return '';
        }
      }, __safe, __objSafe = __obj.safe, __escape = __obj.escape;
      __safe = __obj.safe = function(value) {
        if (value && value.ecoSafe) {
          return value;
        } else {
          if (!(typeof value !== 'undefined' && value != null)) value = '';
          var result = new String(value);
          result.ecoSafe = true;
          return result;
        }
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