all::

CONVERT = convert
CURL = curl -f
RM = rm -f

c/fire.png: url=https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/240/apple/129/fire_1f525.png
c/data.jpg: url=https://images.huffingtonpost.com/2012-04-19-Data2copy.jpg
c/droplet.png: url=https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/240/apple/129/droplet_1f4a7.png

all:: data-feelin-the-heat.png

data-feelin-the-heat.png: c/fire.png c/data.jpg c/droplet.png
	$(CONVERT) c/fire.png \
		\( c/data.jpg \
			-fuzz 25% -fill none -draw "alpha 0,0 floodfill" -draw "alpha 381,0 floodfill" \
			-channel alpha -blur 0x1 -level 50x100% +channel \
			-gravity south -chop 0x118 \
			-resize 160x160 -repage +0+20 \) \
		\( c/droplet.png \
			-resize 48x48 -repage +90+46 \) \
			-background none -flatten +repage \
		$@

c/hst-sm4.jpeg: url=https://upload.wikimedia.org/wikipedia/commons/3/3f/HST-SM4.jpeg

all:: hst.png

hst.png: c/hst-sm4.jpeg
	$(CONVERT) $< \
		-alpha set -bordercolor black -border 1 -fill none -fuzz 8% -draw "color 0,0 floodfill" \
		-shave 1x1 -trim \
		$@

all:: hst-favicon.ico

hst-favicon.ico: hst.png
	$(CONVERT) $< \
		-background none -gravity center -resize 64x64 -extent 64x64 \
		-define icon:auto-resize=64,48,32,16 \
		$@

all:: hst-spinner.gif

hst-spinner.gif: hst.png

c/hotdog.png: url=https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/240/apple/155/hot-dog_1f32d.png

all:: spindog.gif

spindog.gif: c/hotdog.png

# Magically make spinning gifs from any image.
%.gif:
	$(CONVERT) \
		-alpha set -background none \
		-delay 5 \
		-gravity center \
		-dispose previous \
		$< -resize 34x34 \
		-extent 48x48 +repage \
		-duplicate 23 -distort ScaleRotateTranslate %[fx:t*360/n] \
		-trim -layers TrimBounds \
		-loop 0 \
		$@

# Download and cache inputs using the url variable.
c/%:
	@mkdir -p c/
	$(CURL) -o $@ $(url)
	touch $@

clean-cache:
	$(RM) -r c/

clean:
	$(RM) *.png *.ico *.gif

distclean: clean clean-cache

.PHONY: all clean clean-cache distclean
