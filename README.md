# nbnet-sunder

[Sunder](https://github.com/ashn-dot-dev/sunder) bindings for [nbnet](https://github.com/nathhB/nbnet).

## Build and Install
### Native UDP Driver

```sh
$ make
```

### Native WebRTC Driver

```sh
$ make CFLAGS="-DNBN_WEBRTC_NATIVE -I /path/to/libdatachannel/include"
```

### Install
Install to `$(SUNDER_HOME)/lib/nbnet`:

```sh
$ make install
```

## License
All content in this repository is licensed under the Zero-Clause BSD license.

See LICENSE for more information.
