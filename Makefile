LIBS = $(wildcard index.coffee lib/*.coffee)
LIB_JS = $(LIBS:%.coffee=%.js)
TESTS = $(wildcard test/*.coffee)
TEST_JS = $(TESTS:%.coffee=%.js)
VENDOR_JS = lib/vendor.js

.DEFAULT_TARGET = default
default: $(LIB_JS) $(VENDOR_JS)

.PHONY: default test clean

test: default $(TEST_JS)
	mocha --ignore-leaks $(TEST_JS)

clean:
	rm -f $(LIB_JS)
	rm -f $(TEST_JS)
	rm -f $(VENDOR_JS)

%.js: %.coffee
	coffee -c $<

$(VENDOR_JS): vendor/*.js vendor_exports.js
	cat $^ > $@
