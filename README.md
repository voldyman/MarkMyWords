MarkMyWords
-------------------

a minimal markdown editor


**status**: work in progress

###Screenshot

![screenshot](https://github.com/voldyman/MarkMyWords/raw/master/screenshots/scr.png)

Author: Akshay Shekher

## How to build
sudo apt-get install libwebkit2gtk-3.0-dev 
git clone https://github.com/voldyman/MarkMyWords.git
mkdir build && cd build 
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/usr ../
make
