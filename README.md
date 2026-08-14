# CranePKDServerFix

Fixes Crane push notification delivery on iOS 17 with RootHide.

Crane hooks a legacy `PKDServer` initializer, while iOS 17 uses `proxyFactory:` initializers. This leaves Crane without a server instance and causes `pkd` to wait forever. The tweak captures the active instance and exposes it through `+[PKDServer server]`.

## Build

```sh
make package FINALPACKAGE=1 DEBUG=0 THEOS=~/theos-roothide
```
