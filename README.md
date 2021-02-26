# checksum
It is a lightweight tool that adds several items on context menu, which can give checksum, sends them to clipboard, or dump them to a file, on one click.

## Usage

Run `deploy.bat` **as administrator**. Select algorithms and options, and confirm your choices.

##### Algorithms

| #    | algorithms |
| ---- | ---------- |
| 1    | MD2        |
| 2    | MD4        |
| 4    | MD5        |
| 8    | SHA1       |
| 16   | SHA256     |
| 32   | SHA384     |
| 64   | SHA512     |

##### Options

| #    | option                                  |
| ---- | --------------------------------------- |
| 128  | Cascaded context menu*                  |
| 256  | Also add lowercase output mode          |
| 512  | Also add quietly-copy-to-clipboard mode |
| 1024 | Also add output-to-file mode            |

*\* If cascaded context menu is enabled, at most 16 items can be added.*

##### Uninstall

| #    | option    |
| ---- | --------- |
| 0    | Uninstall |

You can add the numbers (#) to select multiple algorithms/options.

E.g. `4+16+128` or `148` means deploy `MD5`, `SHA256`, and put them in a sub menu.

Peculiarly, a trailing `L` means `lowercase output only`, a trailing `Y` means to deploy directly and do not prompt for confirmation. `Y` must comes after `L`, if both present.

E.g. `4+16+128LY` means lowercase output only and no need to confirm.

#### Shortcut Keys

If `cascaded context menu` was NOT enabled, it will create shortcut keys only for first algorithm (the one with smallest number (#) is first) as below table.

| key          | item                |
| ------------ | ------------------- |
| <kbd>Q</kbd> | normal output       |
| <kbd>F</kbd> | output to file      |
| <kbd>L</kbd> | lowercase output    |
| <kbd>K</kbd> | output to clipboard |

If `cascaded context menu` is enabled, the submenu's shortcut key is <kbd>Q</kbd>, and <kbd>1</kbd>, <kbd>2</kbd>, ..., <kbd>0</kbd> will be assigned to items in order. Only first 10 items has shortcut keys.

## Principle

It calls the `certutil.exe` and parses its output. `certutil.exe` is a build-in tool in Windows 10/7, Windows Server 2019/2008, and others.
