# homebrew-freecad

![img_0039][img1]![img_0040][img2]

**FreeCAD** is a Free (as in Libre) multiplatform Open Source Parametric 3D CAD software.
**Homebrew** is a MacOSX Package Manager.

[img1]: <https://cloud.githubusercontent.com/assets/4140247/26723866/91e6a282-4764-11e7-9e3b-b8eb4fdc03f1.PNG>
[img2]: <https://cloud.githubusercontent.com/assets/4140247/26723951/f96fd95a-4764-11e7-96eb-4889cab6d246.PNG>

## Overview

#### NOTE: This only a fork of homebrew-freecad, the original repository found you [here]
(https://github.com/FreeCAD/homebrew-freecad)

#### NOTE: If you are looking for the current macOS builds, please download the latest build from [GitHub](https://github.com/FreeCAD/FreeCAD/releases)

#### NOTE: This repository is experimental and used to create native arm64 FreeCAD application.

## Prerequisites

Install [homebrew](http://brew.sh)

## Installing FreeCAD dependencies (FreeCAD developers)

The first step is tap this repository:

```
brew tap ageeye/FreeCAD/freecad
```

We have not provided packages precompiled for arm Macs. We compile all formula from source:

```
brew install -s ageeye/freecad/icu4c@69.1
brew install -s ageeye/freecad/boost@1.76.0
brew install -s ageeye/freecad/coin@4.0.0
brew install -s ageeye/freecad/python@3.9.7
brew install -s ageeye/freecad/python-tk@3.9.7
brew install -s ageeye/freecad/boost-python3@1.76.0
```

```
brew install -s ageeye/freecad/numpy@1.21.2
brew install -s ageeye/freecad/cython@0.29.24
brew install -s ageeye/freecad/matplotlib
```

```
brew install -s ageeye/freecad/med-file@4.1.0
brew install -s ageeye/freecad/opencascade@7.5.3
brew install -s ageeye/freecad/nglib@6.2.2105
brew install -s ageeye/freecad/opencamlib
brew install -s ageeye/freecad/pivy
```

```
brew install -s ageeye/freecad/qt5152
brew install -s ageeye/freecad/pyqt@5.15.2
```

```
brew install -s ageeye/freecad/llvm@13.0.0
brew install -s ageeye/freecad/shiboken2@5.15.2
```

```
brew install -s ageeye/freecad/pyside2
brew install -s ageeye/freecad/pyside2-tools
brew install -s ageeye/freecad/sip@4.19.24
brew install -s ageeye/freecad/swig@4.0.2
brew install -s ageeye/freecad/tbb@2020_u3
brew install -s ageeye/freecad/vtk@9.0.3
```

## Building macOS App

```
brew install ageeye/freecad/freecad --head --with-macos-app --with-vtk9
```

## Know Issues

What ever, reinstall do not work:

```
brew reinstall ageeye/freecad/freecad
```

Please remove first freecad:

```
brew remove ageeye/freecad/freecad
brew install ageeye/freecad/freecad --head --with-macos-app --with-vtk9
```



## TODOs

..


## Recognition

[Sam Nelson](https://github.com/sanelson) originally developed the freecad homebrew recipe repo circa April 2014 
and [transferred it to the FreeCAD organization](https://github.com/FreeCAD/homebrew-freecad/issues/20) in October 2016.
