// EZLive: Easily Build a Private Live Streaming Room Without a Server
#import "/template-en.typ": doc-template

#doc-template(
title: "EZLive: Easily Build a Private Live Streaming Room Without a Server",
date: "September 27, 2025",
body: [

If you want to start a live stream, most people choose domestic platforms like Bilibili, Douyin, and Douyu, or foreign video platforms like Twitch and YouTube.

However, these platforms have their drawbacks. Foreign platforms are very strict regarding copyright; if you play music, you might get taken down easily. Domestic platforms are relatively loose on music copyright but have strict content censorship.

There is already an open-source personal streaming tool called Owncast. Developed in Go, Owncast makes it easy to set up your own streaming room, but it still needs to be hosted on a server, and the configuration is cumbersome.

Addressing these issues, I recently developed a new personal streaming tool named EZLive. It is hosted on GitHub: #link("https://github.com/mistivia/ezlive", "mistivia/ezlive").

EZLive is functionally based on Owncast, but unlike Owncast, it does not require a dedicated public server. EZLive features a built-in SRT streaming server that converts received streams directly into HLS and publishes them to cloud object storage buckets. It supports any AWS S3-compatible object storage platform, including but not limited to: DigitalOcean, Qiniu Cloud, Alibaba Cloud OSS, Tencent Cloud COS, B2, CloudFlare R2, Minio, etc.

Here is how to use it.

= Apply for an S3-Compatible Object Storage Bucket

The operation is similar across various cloud providers, so I won't go into detail here. After completion, you need the following information:


- Bucket Name
- Endpoint
- Region
- Access key
- Secret key

Next, you must allow public access to the elements in the bucket. For AWS S3, the configuration is set in "Permissions", "Bucket Policy":


```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadOnly",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
        }
    ]
}
```

Then, you need to set up Cross-Origin Resource Sharing (CORS). The EZLive project comes with an HLS player hosted on Github Pages: #link("https://github.com/mistivia/ezlive/tree/gh-pages", "mistivia/ezlive/tree/gh-pages")

The access URL is: #link("https://mistivia.github.io/ezlive", "https://mistivia.github.io/ezlive")

Therefore, you need to add: `https://mistivia.github.io` to the cross-origin access list to allow GET operations.

For AWS S3, the configuration involves editing the bucket's "Permissions", "Cross-origin resource sharing (CORS)":

```
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET"
        ],
        "AllowedOrigins": [
            "https://mistivia.github.io"
        ],
        "ExposeHeaders": []
    }
]
```

= Start EZLive

First, go to the releases page to download EZLive: #link("https://github.com/mistivia/ezlive/releases/", "https://github.com/mistivia/ezlive/releases/")

== Windows Platform

Download the binary build for Windows: ezlive-windows.7z

After extracting, create a configuration file named "config" in the ezlive directory, noting that it should have no file extension. Then fill it in using the following format:

```
listening_addr=127.0.0.1
listening_port=61935
bucket=YOUR_BUCKET_NAME
endpoint=https://your-oss.com
s3_path=ezlive/
access_key=YOUR_S3_ACCESS_KEY
secret_key=YOUR_S3_SECRET_KEY
region=YOUR_REGION
```

Then run ezlive.exe.

== Linux Platform

On Linux, using Docker is recommended. Download the Docker image: ezlive-docker-image.tar.gz

Import:

```
cat ezlive-docker-image.tar.gz | gzip -d | sudo docker load
```

Create a conf directory:

```
mkdir conf
```

Create a config file in the conf directory with content basically the same as above. However, since it is inside Docker, the listening address needs to be changed to 0.0.0.0.

```
listening_addr=0.0.0.0
listening_port=61935
bucket=YOUR_BUCKET_NAME
endpoint=https://your-oss.com
s3_path=ezlive/
access_key=YOUR_S3_ACCESS_KEY
secret_key=YOUR_S3_SECRET_KEY
region=YOUR_REGION
```

Finally, run the Docker image

```
sudo docker run -it --rm \
    -v ./conf:/etc/ezlive/ \
    -p 127.0.0.1:61935:61935/udp \
    localhost/ezlive
```

Since I do not have a macOS device at hand, no macOS build is provided. macOS users may need to build from source themselves.

= Streaming

After EZLive starts, you can open OBS to stream. EZLive requires the video stream to be H.264 and the audio stream to be AAC.
EZLive does not process the stream much; it simply converts the container from mpegts to hls.

The streaming address is:

```
srt://127.0.0.1:61935
```

= Playback

After streaming starts, you should be able to see stream.m3u8 and several video segments in the ezlive directory of the object storage bucket.

Assuming the access path for stream.m3u8 is:

```
https://your-bucket.your-oss.com/ezlive/stream.m3u8
```

Then, open the following URL to watch the live stream:

```
https://mistivia.github.io/ezlive#https://your-bucket.your-oss.com/ezlive/stream.m3u8
```

This player has a built-in hack chat service for bullet comments (danmaku). If you don't need this feature, you can use this playback address:

```
https://mistivia.github.io/ezlive/hls.html#https://your-bucket.your-oss.com/ezlive/stream.m3u8
```

If it fails to play, check:

- Whether the link to stream.m3u8 is accessible;
- Whether the player's domain name (https://mistivia.github.io) has been added to the CORS settings.

= Important Notes

For live streaming, storage costs on major cloud providers are almost negligible, but traffic costs are often high, sometimes reaching 0.5 RMB per GB, so pay attention to the costs.

Do not close the EZLive process immediately after ending the stream. Wait for a while; if no new stream is received within one minute, EZLive will automatically delete the live video segments to save cloud storage space.

Additionally, access to GitHub Pages and Hack Chat is unstable in China. If you need barrier-free viewing for domestic users, in addition to trying to use domestic object storage services, you might need to switch to a different HLS player, for example:

```
https://www.livereacting.com/tools/hls-player-embed?url=https://your-bucket.your-oss.com/ezlive/stream.m3u8
```

Note that you need to add the corresponding player domain to the cross-origin settings. For example, for the player above, it would be:

```
https://www.livereacting.com
```

The CORS must be correctly configured to watch the live.

])