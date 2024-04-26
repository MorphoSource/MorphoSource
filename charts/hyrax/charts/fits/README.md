Fits Helm Chart
=========================

The File Information Tool Set (FITS) identifies, validates and extracts technical
metadata for a wide range of file formats. It acts as a wrapper, invoking and
managing the output from several other open source tools. Output from these tools
are converted into a common format, compared to one another and consolidated into
a single XML output file. FITS is written in Java and is compatible with Java 1.8
or higher.


## Installation

```sh
helm repo add fits https://samvera-labs.github.io/fits-charts
helm install fits
```

### Or from local

```sh
helm dep up chart/fits
helm install fits chart/fits
```

### Release a new version

- Bump the version in the Chart.yaml
- Run `helm package .`
- Run `helm repo index . --url https://samvera-labs.github.io/fits-charts`
- Add files to git and push

## Configuration

See https://github.com/harvard-lts/FITSservlet for potential configuration options
