LIBS = $(wildcard node_modules/*.coffee node_modules/*/*.coffee)
LIB_JS = $(LIBS:%.coffee=%.js)
TESTS = $(wildcard test/*.coffee test/*/*.coffee)

.DEFAULT_TARGET = default

%.js: %.coffee
	coffee -c $<

default: $(LIB_JS)

test:
	expresso $(TESTS)

clean:
	rm -f $(LIB_JS)

.PHONY: test clean