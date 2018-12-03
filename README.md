# louis_xvi

A offline password management app, support mobile and desktop(Currently, only MacOS version is tested).

# Project structure

desktop -- contains code related to desktop app, whic use [flutter-desktop-embedding](https://github.com/google/flutter-desktop-embedding) as flutter embedder.

louis_xvi -- a normal flutter app (for desktop support, need to make small modificatino in louis_xvi/lib/main.dart )

# How to build mobile app

It's just a normal flutter app, please follow [instructions](https://flutter.io/docs/get-started/install).

# How to build desktop app

1. get flutter and flutter-desktop-embbeeding

   ```
   cd desktop
   ./setup.sh
   ```

2. build desktop app

   Linux

   ```
   cd linux
   make
   ```

   MacOS

   use Xcode build project under desktop/macos

3. Windows

   use Visual Studio build proejct under desktop/windows
