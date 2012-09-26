LIBS = $(wildcard index.coffee lib/*.coffee)
LIB_JS = $(LIBS:%.coffee=%.js)
TESTS = $(wildcard test/*.coffee)
VENDOR_JS = lib/vendor.js

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

$(VENDOR_JS): vendor/*.js vendor_exports.js
	cat $^ > $@
