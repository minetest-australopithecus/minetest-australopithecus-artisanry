doc := doc
test := test


all: doc test

clean:
	$(RM) -R $(doc)

.PHONY: doc
doc:
	ldoc --dir=$(doc) mods/artisanry

.SILENT .PHONY: test
test: $(test)/*.lua
	$(foreach file,$^,lua $(file);)

