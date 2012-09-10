LIBS = $(wildcard node_modules/*.coffee node_modules/*/*.coffee)
LIB_JS = $(LIBS:%.coffee=%.js)
TESTS = $(wildcard test/*.coffee test/*/*.coffee)
VENDOR_JS = node_modules/one_pass/vendor.js

.DEFAULT_TARGET = default
default: $(LIB_JS) $(VENDOR_JS)

.PHONY: default test clean

test: default
	expresso $(TESTS)

clean:
	rm -f $(LIB_JS)
	rm -f $(VENDOR_JS)

%.js: %.coffee
	coffee -c $<

$(VENDOR_JS): vendor/*.js
	cat $^ vendor_exports.js > $@
