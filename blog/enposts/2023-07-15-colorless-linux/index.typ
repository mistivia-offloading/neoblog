// Colorless Linux
#import "/template-en.typ":*
#doc-template(
title: "Colorless Linux",
date: "July 15, 2023",
body: [

The reason for this started when I read an article: "#link("https://www.wsj.com/video/series/wsj-explains/cant-put-down-your-phone-try-turning-it-grayscale/7B76B4EA-26D0-4F5B-9097-4B3B8B9B167E")[Can't Put Down Your Phone? Try Turning It Grayscale]"

A new study shows that turning your phone screen to black and white is more effective than using applications to limit usage time.

Both iOS and Android have built-in functions to turn the screen display into black and white grayscale, mainly for color-blind groups. Windows 10 also has a similar function. I don't have a macOS device at hand right now, but since it's on iOS, there's no reason why it wouldn't be on macOS.

The problem comes to Linux. Linux does not provide such tools natively. The only one relatively close is #link("https://github.com/jonls/redshift")[RedShift]. However, the principle of this tool is to adjust Gamma values, so it can only adjust the ratio of red, green, and blue colors, but cannot turn the screen into grayscale.

Finally, the solution I found was to use #link("https://github.com/yshui/picom")[picom].

Picom is an X compositor that supports OpenGL rendering, so you can write an OpenGL shader yourself to control the display effect:

```
#version 330

in vec2 texcoord;
uniform sampler2D tex;

vec4 window_shader() {
	vec4 c = texelFetch(tex, ivec2(texcoord), 0);

	float grayscale = c.x * 0.299 + c.y * 0.587 + c.z * 0.114;
	c.x = grayscale;
	c.y = grayscale;
	c.z = grayscale;
	return c;
}
```

Because human eyes have different sensitivity to red, green, and blue colors, the NTSC color-to-black-and-white formula is used here. Red, green, and blue are mixed in a ratio of 0.299:0.587:0.114 to calculate the grayscale value, and then red, green, and blue are all set to this grayscale value to convert the color image to black and white. In fact, using the average value of the intensities of the three colors also works, and the effect is similar.

Save the shader in `~/.picom.glsl`, and then run picom:

```
picom --backend glx --window-shader-fg '/home/mistivia/.picom.glsl' &
```

You can see the screen turn black and white. If you want it to execute automatically at startup, you can put this line of command into `.xinitrc`. If you want to restore it to color, just kill the picom process.

])
