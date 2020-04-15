# Build FFMpeg with brew on macOS

- Base on offical static build: [Static builds for macOS 64-bit](https://evermeet.cx/ffmpeg/)
- Add AAC support
- Add SSL support (with OpenSSL)
- Build for macOS target version: `10.9+`

## Useage

### Install [Homebrew](https://brew.sh)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

### Build FFMpeg with shell script

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/cntrump/build_ffmpeg_brew/master/build.sh)"
```
