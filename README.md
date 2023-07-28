# slipy

A forked Slidy project.

CLI script pipeline, package manager and template generator for Flutter. Generate Modules, Pages, Widgets, BLoCs, Controllers, tests and more.

# Installation

You can get slipy of many ways.

## choco (only windows)

```bash
choco install slipy
```

## Homebrew (macos and linux)

```bash
brew tap fernandormoraes/slipy
brew install slipy
```

## Other OS

All binary releases, [click here](https://github.com/fernandormoraes/slipy/releases).

## Flutter/Dart directly

```bash
 dart pub global activate slipy
```

## Hello world!

After install, exec the slipy version command.
If the command was completed, the slipy was installed.

```bash
 slipy --version
```

# slipy pipeline


Organize scripts to be executed by automating processes. All steps can be
configured in a file called `slipy.yaml`.
```
slipy run cleanup
```

**slipy.yaml**:
```yaml 
slipy: '1'
variables:
  customMessage: "Complete"    # Gets  ${Local.var.customMessage}

scripts:
  # Simple command (slipy run doctor)
  doctor: flutter doctor

  # Descritive command (slipy run clean)
  clean:
    name: "Clean"
    description: 'minha descricao'
    run: flutter clean

  # Steped command (slipy run cleanup)   
  cleanup:
    description: "cleanup project"
    steps:
      - name: "Clean"
        run: flutter clean
        
      - name: "GetPackages"
        description: "Get packages"
        run: flutter pub get

      - name: "PodClean"
        description: "Execute pod clean"
        shell: bash   # default: command. options (command|bash|sh|zsh|pwsh)
        condition: "${System.operatingSystem} == macos"
        working-directory: ios
        run: |-
          rm Podfile.lock
          pod deintegrate
          pod update
          pod install

      - run: echo ${Local.var.customMessage} 
```

## Propeties

| Propetie    |      Type        |  Doc |
|:----------  |:-----------------|:------|
| slipy       | string         | slipy pipeline version |
| variables   | object         | Local variables. ex:<br>${Local.var.[VariableName]} |
| scripts     | object         | Add runnable scripts by name |

## Script Propetie

Add custom scripts. <br>
The property name can be invoked using the `slipy run` command.

**Simple example:**

```yaml
...
scripts:
  runner: flutter pub run build_runner build --delete-conflicting-outputs
...
```
Execute this script using ``slipy run runner`

**Complete example:**

```yaml
...
scripts:
  runner: 
    name: "Runner"
    description: "Execute build_runner"
    run: flutter pub run build_runner build --delete-conflicting-outputs
...
```

| Propetie                 |      Type        |  Doc |
|:----------               |:-----------------|:------|
| run                      | string           | script to run |
| name                     | string           | Script name |
| description              | string           | Script description |
| shell                    | string           | options: <br>- command(default)<br>- bash<br>- sh<br>- zsh<br>- pwsh) |
| working-directory        | string           | Run folder  |
| environment              | object           | Add environment variable.|
| steps                    | array(Step)      | Run multiple scripts in sequence..|

**NOTE**: The STEPS or RUN property must be used. It is not allowed to use both at the same time.


**Stepped example:**

```yaml
scripts:
  cleanup:
    description: "cleanup project"
    steps:
      - name: "Clean"
        run: flutter clean
        
      - name: "GetPackages"
        description: "Get packages"
        run: flutter pub get

      - name: "PodClean"
        description: "Execute pod clean"
        shell: bash 
        condition: "${System.operatingSystem} == macos"
        working-directory: ios
        run: |-
          rm Podfile.lock
          pod deintegrate
          pod update
          pod install

      - run: echo ${Local.var.customMessage} 
```

| Step Propetie                 |      Type        |  Doc |
|:----------               |:-----------------|:------|
| run                      | string           | script to run |
| name                     | string           | Script name |
| description              | string           | Script description |
| shell                    | string           | options: <br>- command(default)<br>- bash<br>- sh<br>- zsh<br>- pwsh) |
| working-directory        | string           | Run folder  |
| environment              | object           | Add environment variable.|
| condition                | boolean      |If true, execute this script. |

**NOTE**: The main file is called `slipy.yaml`, but if you want to call other files, use the **--schema** flag of the run command. <br>`slipy run command --schema other.yaml`


# Package manager
Install, Uninstall and find package by command line.
```bash
# install package
slipy install bloc

# install package with version
slipy install flutter_modular@4.0.1

# install package in dev_dependencies
slipy install mocktail --dev

# find package by query
slipy find "Shared preferences"

# show package versions
slipy versions dio
```

# Template generator
slipy's goal is to help you structure your project in a standardized way. Organizing your app in **Modules** formed by pages, repositories, widgets, BloCs, and also create unit tests automatically. The Module gives you a easier way to inject dependencies and blocs, including automatic dispose. Also helps you installing the dependencies and packages, updating and removing them. The best is that you can do all of this running a single command.

We realized that the project pattern absence is affecting the productivity of most developers, so we're proposing a development pattern along with a tool that imitates NPM (NodeJS) functionality as well as template generation capabilities (similar to Scaffold).


## About the Proposed Pattern

The structure that slipy offers you, it's similar to MVC, where a page keeps it's own **business logic classes(BloC)**.

We recommend you to use [flutter_modular](https://pub.dev/packages/flutter_modular) when structuring with slipy. It offers you the **module structure**(extending the WidgetModule) and dependency/bloc injection, or you will probably get an error.

To understand **flutter_modular**, take a look at the [README](https://github.com/fernandormoraes/modular/blob/master/README.md).

We also use the **Repository Pattern**, so the folder structure it's organized in **local modules** and a **global module**. The dependencies(repositories, BloCs, models, etc) can be accessed throughout the application.

Sample folder structure generated by **slipy**:


## Commands

**start:**
Create a basic structure for your project (confirm that you have no data in the "lib" folder).

```
slipy start
```

## Generate

Create a module, page, widget or repository according to the option.<br>
slipy generator supports mobx, bloc, cubit, rx_notifier and triple.

**Options:**

Creates a new module with **slipy generate module**:

```
slipy generate module manager/product
```

Creates a new page with **slipy generate page**:

```
slipy generate page manager/product/pages/add_product
```

Creates a new widget with **slipy generate widget**:

```
slipy generate widget manager/product/widgets/product_detail
```

Create a new repository with **slipy generate repository**

```
slipy g r manager/product/repositories/product
```

Create a new rx notifier with **slipy generate rx**

```
slipy g rx manager/product/page/my_rx_notifier
```

Create a new triple with **slipy generate t**

```
slipy g t manager/product/page/my_triple
```

Create a new cubit with **slipy generate c**

```
slipy g c manager/product/page/my_cubit
```

Create a new mobx with **slipy generate mbx**

```
slipy g mbx manager/product/page/my_store
```

For more details [Telegram Group fernandormoraes](https://t.me/flutterando)
