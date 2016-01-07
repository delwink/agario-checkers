OUT=agario-checkers.love
DATA=COPYING COPYING.CC-BY-SA README res/ TRADEMARKS
SOURCES=board.lua button.lua class.lua conf.lua geom.lua main.lua piece.lua

all: zip

zip:
	zip -ru $(OUT) $(DATA) $(SOURCES)
