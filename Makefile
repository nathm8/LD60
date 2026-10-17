clean:
	rm -fr bin/

runjs: buildjs
	chromium index.html

buildjs:
	haxe js.hxml

buildhl:
	haxe hl.hxml

runhl: buildhl
	hl ./bin/game.hl

push: clean buildjs
	rm -f LD60.zip
	zip -r LD60.zip index.html bin/game.js bin/game.js.map
	butler push LD60.zip nathmate/LD60:HTML
	git push