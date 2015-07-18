OUT=agario-checkers.love
DATA=COPYING README res/
SOURCES=board.lua class.lua conf.lua main.lua piece.lua

all: zip

zip:
	zip -ru $(OUT) $(DATA) $(SOURCES)
