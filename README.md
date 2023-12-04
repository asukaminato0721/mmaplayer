# mmaplayer

show interactive result in wolfram player.

Make sure you have `wolframscript` and `wolframplayer` in your `PATH`.

## Feature

- official style
- free
- interactive
- can be used with any text-based file
- support all \*Plot\* functions and their options
- won't crash the notebook

## Install

<https://code.visualstudio.com/docs/editor/extension-marketplace#_install-from-a-vsix>

vsix can be downloaded from <https://github.com/asukaminato0721/mmaplayer/releases>

---

## Usage

click the <kbd>Play it</kbd>

## Screenshot

basic plot

![Plot](https://i.imgur.com/M5hDikK.png)

code from <https://mathematica.stackexchange.com/a/5280/68689>

![Control](https://i.imgur.com/KWceqHR.png)

```mma
ComplexPlot3D[z + 1/z, {z, -2 - 2 I, 2 + 2 I}, 
 ColorFunction -> "DarkRainbow", PlotLegends -> Automatic]
```

![3D](https://i.imgur.com/dJyFUIO.png)

---

## Development

<kbd>F5</kbd>

## Build

```sh
vsce package
```

No `node_modules`

## Acknowledge

<https://github.com/arnoudbuzing/wolfram-server> for the server.
