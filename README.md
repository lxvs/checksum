# checksum
It is a lightweight tool that adds several items on context menu, which can give checksum, sends them to clipboard, or dump them to a file, on one click.

## Algorithms supported

- MD2
- MD4
- MD5
- SHA1
- SHA256
- SHA384
- SHA512

## Another options

- cascaded context menu, or not
- lowercase output mode
- quietly-copy-to-clipboard mode
- output-to-file mode
- uninstall

## Principle

It calls the `certutil.exe` and parses its output. `certutil.exe` is a build-in tool in Windows 10/7, Windows Server 2019/2008, and others.
