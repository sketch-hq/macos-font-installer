# MacOS font installer

This is a small script to install all freely downloadable fonts into a Mac OS computer.
We use it to install all fonts we need in the renderfarm machines.

## Deployment

Any commit to a branch builds a version, you can access it from CircleCI artifacts.
Any version tag (vX.Y.Z) will triger a release and will upload the binaries to a github release.
