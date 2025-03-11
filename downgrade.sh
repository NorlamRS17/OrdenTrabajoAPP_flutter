CURRENT_PATH=$PWD
cd ~/snap/flutter/common/flutter
git checkout 2.10.5
flutter downgrade v2.10.5
flutter doctor
flutter --version
cd $CURRENT_PATH
flutter clean
flutter pub get