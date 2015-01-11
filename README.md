# MarkMyWords

A minimal markdown editor

**Status**: work in progress

Installation:
* AUR package by [emersion](https://github.com/emersion) at https://github.com/emersion/aur-markmywords
* PPA: _ppa:voldyman/markmywords_
  
  ```shell
  sudo add-apt-repository ppa:voldyman/markmywords
  sudo apt-get update
  sudo apt-get install mark-my-words
  ```

## Screenshot

![screenshot](https://github.com/voldyman/MarkMyWords/raw/master/screenshots/screenshot-2015-1-4.png)

Author: Akshay Shekher

## How to build

```shell
sudo apt-get install libwebkit2gtk-3.0-dev 
sudo apt-get install libgtksourceview-3.0-dev
git clone https://github.com/voldyman/MarkMyWords.git
mkdir build && cd build 
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/usr ../
make
```

## Todo

- [x] Markdown Parsing
- [x] Live Preview
- [x] File IO
- [x] State management
- [x] Export HTML
- [ ] Export PDF
- [ ] Github markdown
- [ ] Preferences
