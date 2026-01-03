# openvscode-server-flutter

OpenVSCode Server with Dart and Flutter ready

Based on [openvscode-server](https://github.com/gitpod-io/openvscode-server) with Dart and Flutter SDK preinstalled. Also Dart and Flutter VS Code extensions are included. Works fine behined a reversed proxy like Traefik.

Image build args:

| Argument | Example | Description |
| - | - | - |
| `FLUTTER_VERSION` | 3.22.1 | Desirable Flutter Stable Version |

To run a Flutter app execute:

```shell
flutter run --debug --hot -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

NB: Due to some issues with Hot reload and Hot restart on the latest Flutter versions since 3.35 and later on when you are serving your project behind a reverse proxy like Traefik via https you might want to avoid browser errors like "Mixed Content... requested an insecure XMLHttpRequest endpoint" adding `--no-web-experimental-hot-reload` to the command:
```shell
flutter run --debug --hot -d web-server --web-hostname 0.0.0.0 --web-port 8080 --no-web-experimental-hot-reload
```

## Features

- Dart and Flutter SDK preinstalled
- Dart and Flutter VSCode extensions preinstalled
- Oh My Bash with default theme preinstalled
- Flutter completion for Bash added
- FVM preinstalled

Happy coding 🧑🏻‍💻
