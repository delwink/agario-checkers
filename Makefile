OUT=agario-checkers.love
DATA=README COPYING
SOURCES=class.lua conf.lua event.lua main.lua piece.lua

all: zip

zip:
	zip -u $(OUT) $(DATA) $(SOURCES)
