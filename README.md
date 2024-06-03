# B(l)utter
Flutter Mobile Application Reverse Engineering Tool by Compiling Dart AOT Runtime

Currently the application supports only Android libapp.so (arm64 only).
Also the application is currently work only against recent Dart versions.

For high priority missing features, see [TODO](#todo)


## Environment Setup
This application uses C++20 Formatting library. It requires very recent C++ compiler such as g++>=13, Clang>=16.

I recommend using Linux OS (only tested on Deiban sid/trixie) because it is easy to setup.

### Debian Unstable (gcc 13)
- Install build tools and depenencies
```
apt install python3-pyelftools python3-requests git cmake ninja-build \
    build-essential pkg-config libicu-dev libcapstone-dev
```

### Windows
- Install git and python 3
- Install latest Visual Studio with "Desktop development with C++" and "C++ CMake tools"
- Install required libraries (libcapstone and libicu4c)
```
python scripts\init_env_win.py
```
- Start "x64 Native Tools Command Prompt"

### macOS Ventura and Sonoma (clang 16)
- Install XCode
- Install clang 16 and required tools
```
brew install llvm@16 cmake ninja pkg-config icu4c capstone
pip3 install pyelftools requests
```

### Docker / podman

- Create volumes for cached blutter builds (first-time only):

#### rootless (podman)

```shell
for vol in blutter-bin blutter-pkg; do
  $DOCKER volume create $vol
done
```

#### root-mode (docker)

```shell
for vol in blutter-bin blutter-pkg; do
  # option 1: just create classical folders you'll bind mount the /blutter cache folders, e.g.:
  mkdir -p "~/.local/share/docker/volumes/$vol"
  # or option 2: a bit dirty
  $DOCKER volume create $vol && sudo chown $(id -u):$(id -g) /var/lib/docker/volumes/$vol/_data
done
```

- Create an alias for blutter command (choose appropriate depending on your containerd backend):

```shell
function blutter() {
  [[ "$1" == "-h" ]] && echo "Please provide decompressed apk directory." && return
  # podman (rootless)
  podman run --userns=keep-id --rm -v "blutter-bin:/blutter/bin" -v "blutter-pkg:/blutter/packages" -v "$(readlink -f "${1:-.}"):/apk" blutter /apk ${@:2}
  # docker (replace mount points if you used option 1 for volumes)
  docker run --rm -v "blutter-bin:/blutter/bin" -v "blutter-pkg:/blutter/packages" -v "$(readlink -f "${1:-.}"):/apk" blutter /apk ${@:2}
}
```

- First build (or after a code update): define your containerd backend and run make: `DOCKER=docker make` or `DOCKER=podman make`
  - Note that after a code update, you should wipe `blutter-bin` volume data

## Usage
Extract "lib" directory from apk file
```
python3 blutter.py path/to/app/lib/arm64-v8a out_dir
```
The blutter.py will automatically detect the Dart version from the flutter engine and call executable of blutter to get the information from libapp.so.

If the blutter executable for required Dart version does not exists, the script will automatically checkout Dart source code and compiling it.

### Docker

- Unzip your app: `apktool d my-app.apk`
- Run the blutter command: `blutter my-app`

The output will be in `my-app/blutter_out` directory.

## Update
You can use ```git pull``` to update and run blutter.py with ```--rebuild``` option to force rebuild the executable
```
python3 blutter.py path/to/app/lib/arm64-v8a out_dir --rebuild
```

## Output files
- **asm/\*** libapp assemblies with symbols
- **blutter_frida.js** the frida script template for the target application
- **objs.txt** complete (nested) dump of Object from Object Pool
- **pp.txt** all Dart objects in Object Pool


## Directories
- **bin** contains blutter executables for each Dart version in "blutter_dartvm\<ver\>\_\<os\>\_\<arch\>" format
- **blutter** contains source code. need building against Dart VM library
- **build** contains building projects which can be deleted after finishing the build process
- **dartsdk** contains checkout of Dart Runtime which can be deleted after finishing the build process
- **external** contains 3rd party libraries for Windows only
- **packages** contains the static libraries of Dart Runtime
- **scripts** contains python scripts for getting/building Dart


## Generating Visual Studio Solution for Development
I use Visual Studio to delevlop Blutter on Windows. ```--vs-sln``` options can be used to generate a Visual Studio solution.
```
python blutter.py path\to\lib\arm64-v8a build\vs --vs-sln
```

## TODO
- More code analysis
  - Function arguments and return type
  - Some psuedo code for code pattern
- Generate better Frida script
  - More internal classes
  - Object modification
- Obfuscated app (still missing many functions)
- Reading iOS binary
- Input as apk or ipa
