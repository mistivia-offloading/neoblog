#!/bin/sh

make
tail -n+4 blog/posts/index.md | head -n10 | python genrss.py > output/blog/index.xml
tail -n+6 blog/enposts/index.md | head -n10 | python genrss.py > output/blog/enposts/index.xml
git add *
git commit -am "update"
proxychains -q git push
cp output/homepage/style*.css output/blog/
cp output/homepage/style*.css /var/ygg/web/

rsync -avz --delete output/blog/ root@raye:/volume/webroot/blog/
rsync -avz --delete output/homepage/ root@raye:/volume/webroot/homepage/
cp output/blog/index.html /var/ygg/web/blog.html
cp output/blog/index.xml /var/ygg/web/index.xml
rsync -avz --delete output/blog/posts/ /var/ygg/web/posts/
rsync -avz --delete output/blog/enposts/ /var/ygg/web/enposts/
sed -i 's#https://mistivia.com#/#g' /var/ygg/web/blog.html
