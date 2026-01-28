// Some FFmpeg Tips
#import "/template-en.typ":*

#doc-template(
title: "Some FFmpeg Tips",
date: "January 18, 2022",
body: [

= Burning Subtitles

If you want to load subtitles for a video, it is actually most convenient to load a text-format subtitle track or subtitle file separately. However, if the video is to be uploaded to some websites or viewed on mobile devices, you may need to burn the subtitles into the video. FFmpeg provides a command:

```
ffmpeg -i input.mp4 -vf "ass=subtitle.ass" output.mp4
```

Some subtitles are in `*.srt` format, in which case they need to be transcoded to `*.ass` format first:

```
ffmpeg -i input.srt output.ass
```

If the subtitle is a subtitle track in an MKV file, it needs to be extracted first:

```
ffmpeg -i Movie.mkv -map 0:s:0 subs.srt
```

Here `0:s:0` represents the first subtitle track. Because sometimes a video file contains multiple subtitle tracks in different languages, for example, many videos downloaded from Netflix. If you want to select other subtitle tracks, such as the second one, change the `-map` parameter to `0:s:1`.

= Merging Audio Files

To merge audio files, you first need to list the files and put them in a text file, like this:

```
file track-01.mp3
file track-02.mp3
file track-03.mp3
...
file track-XX.mp3
```

Assuming the above file is saved as `list.txt`, then run this command:

```
ffmpeg -f concat -safe 0 -i list.txt -c copy output.mp3
```

= Converting Video to GIF

You can actually use FFmpeg to convert video directly to GIF:

```
ffmpeg -i input.mp4 output.gif
```

However, if converted directly, vertical and horizontal stripes will appear on the GIF image. Actually, there is a technical term in the field of digital signal processing to describe this: #link("https://en.wikipedia.org/wiki/Dither")[Dither].

Since GIF only has a limited number of colors to choose from, there will inevitably be losses when converting videos, and dither can be used to reduce quantization errors at this time.

However, although theoretically speaking, the quantization error is reduced, it actually looks uncomfortable to the human eye, so it is best to turn off dither. But in this case, the steps are a bit more complicated. First, generate a GIF palette:

```
ffmpeg -i input.mp4 -vf palettegen palette.png
```

Then, combine the palette file and start transcoding with dither disabled:

```
ffmpeg -i input.mp4 -i palette.png \
    -filter_complex "paletteuse=dither=none" output.gif
```

In this way, you can get a satisfactory GIF image.

])
