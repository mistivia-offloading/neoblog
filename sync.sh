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
rsync -avz --delete output/blog/ /var/ygg/web/blog/
sed -i 's#href="https://mistivia.com"#href="http://\[200:2829:50f2:e2f1:96e1:3d6d:e107:b39f\]/"#g' /var/ygg/web/blog/index.html
