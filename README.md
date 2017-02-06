# pdfpop

A very simple macOS command line utility for creating PDFs from an existing
PDF.


## Build

**Note:** Xcode command line tools are required.

```shell
$ git clone https://github.com/tweekmonster/pdfpop
$ cd pdfpop
$ make
```


## Usage

It accepts 3 arguments:

- `-in`: The source PDF file
- `-out`: The output PDF file (optional)
- `-range`: A range of pages

If `-out` is not specified, the source PDF filename is used with the current
date and time appended.

A range of pages can be a single number:

```
$ pdfpop -in file.pdf -range 2
```

Or an actual range of pages (must be ascending order):

```
$ pdfpop -in file.pdf -range 2-5
```

Or an list of page ranges:

```
$ pdfpop -in file.pdf -range 2-5,10,20-30
```


## License

[MIT](LICENSE)
