#!/usr/bin/env bash
cd $HOME
if [[ -f .temp_slipy_installer ]]
then
  rm -rf .temp_slipy_installer
fi

mkdir $(pwd)/.temp_slipy_installer

cd $(pwd)/.temp_slipy

THEARCH=$(uname -m)
THEBIT=$(getconf LONG_BIT)

if [[ $THEBIT == *64* ]]; then

  echo "downloading the lastest slipy' version!"
  THEURL=$(curl -s https://api.github.com/repos/fernandormoraes/slipy/releases | grep browser_download_url | grep 'linux-x64[.]tar[.]gz' | head -n 1 | cut -d '"' -f 4)
  curl -L $THEURL > slipy_temp.tar.gz

fi

if [[ $THEBIT == *64* ]]; then

  echo "downloading the lastest slipy' version!"
  THEURL=$(curl -s https://api.github.com/repos/fernandormoraes/slipy/releases | grep browser_download_url | grep 'linux-ia32[.]tar[.]gz' | head -n 1 | cut -d '"' -f 4)
  curl -L $THEURL > slipy_temp.tar.gz

fi

tar -xvzf slipy_temp.tar.gz
sudo cp slipy/slipy /usr/bin/

echo "Cleaning environment ..."
cd $HOME
rm -rf .temp_slipy_installer

slipy -v 