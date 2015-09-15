deps := deps
doc := doc
mod_name := artisanry
mods := mods
release := release
release_name := artisanry

all: doc

clean:
	$(RM) -R $(doc)

.PHONY: doc
doc:
	ldoc --dir=$(doc) mods/$(mod_name)

.PHONY: release
release:
	# Prepare the directory structure.
	mkdir -p $(release)/
	mkdir -p $(release)/$(release_name)/
	mkdir -p $(release)/$(release_name)/mods/
	
	# Copy the dependencies.
	cp -R $(deps)/utils/utils $(release)/$(release_name)/mods/
	
	# Copy the mods.
	cp -R $(mods)/$(mod_name) $(release)/$(release_name)/mods/
	
	# Copy the files.
	cp LICENSE $(release)/$(release_name)/
	cp README $(release)/$(release_name)/
	
	tar -c --xz -C $(release) -f $(release)/$(release_name).tar.xz $(release_name)/
	tar -c --gz -C $(release) -f $(release)/$(release_name).tar.gz $(release_name)/
	cd $(release); zip -r -9 $(release_name).zip $(release_name); cd -
	
.PHONY: update-deps
update-deps:
	git submodule foreach git pull origin master
	git add $(deps)/
	git commit -m "Updated dependencies."

