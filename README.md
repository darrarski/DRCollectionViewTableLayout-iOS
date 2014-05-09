DRCollectionViewTableLayout
===========================

Tested under iOS 7, should work on iOS 6 without a problem. If you are looking for specific version of the library, checkout those branches:

- For development version - [master branch](../../tree/master)
- For v1.x.y - [branch v1](../../tree/v1)

## Installation

You can install the library using CocoaPods. To do so, you will need to add one of the following lines to your Podfile:

For most recent or development version:

	pod 'DRCollectionViewTableLayout', :git => 'https://github.com/darrarski/DRCollectionViewTableLayout'

For specific version:

	pod 'DRCollectionViewTableLayout', :git => 'https://github.com/darrarski/DRCollectionViewTableLayout', :branch => "VERSION_BRANCH"

Where `VERSION_BRANCH` you should put the branch name for given version (ex. "v1"). It is recommended to set version branch explicity, as backward compatibility between those branches is not warranted. Master branch always contains the most recent version.

## Usage

Public methods of the library are documented in-code. For detailed examples check out attached demo project.

## License

Code in this project is available under the MIT license.

## Credits

The library is using concepts from:

- [KEZCollectionViewTableLayout by ketzusaka](https://github.com/ketzusaka/KEZCollectionViewTableLayout)

