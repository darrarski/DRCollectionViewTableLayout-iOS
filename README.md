DRCollectionViewTableLayout
===========================

`UICollectionViewLayout` for displaying 2D tables, similar to those in spreadsheets. Library contains layout class and `DRCollectionViewTableLayoutManager` that acts as a proxy and allows to configure collection view, and propagate it with data in easy way. For example implementation, checkout attached demo project.

Tested under iOS 7, should work on iOS 6 without a problem. If you are looking for specific version of the library, checkout those branches:

- For development version - [master branch](../../tree/master)
- For v1.x.y - [branch v1](../../tree/v1)

Demo project is configured to display a table with column and row headers. Each cell has randomly generated color. Labels in cells contains `UICollectionView` indexPath for given cell, as well as layout's column and row number. Labels in headers contains `UICollectionView` section number, and layout's column/row number.

![DRCollectionViewTableLayout screenshot 1](Screenshots/iOS%20Simulator%20Screen%20shot%2009%20May%202014%2016.52.02.png "DRCollectionViewTableLayout screenshot 1")

`DRCollectionViewTableLayout` alows you to easily setup floating headers for columns as well as rows. Sticky headers behaviour is similar to `UITableView` headers.

![DRCollectionViewTableLayout screenshot 2](Screenshots/iOS%20Simulator%20Screen%20shot%2009%20May%202014%2016.52.27.png "DRCollectionViewTableLayout screenshot 2")

## Installation

You can install the library using CocoaPods. To do so, you will need to add one of the following lines to your Podfile:

For most recent or development version:

	pod 'DRCollectionViewTableLayout', :git => 'https://github.com/darrarski/DRCollectionViewTableLayout'

For specific version:

	pod 'DRCollectionViewTableLayout', :git => 'https://github.com/darrarski/DRCollectionViewTableLayout', :branch => 'VERSION_BRANCH'

Where `VERSION_BRANCH` you should put the branch name for given version (ex. "v1"). It is recommended to set version branch explicity, as backward compatibility between those branches is not warranted. Master branch always contains the most recent version.

## Usage

Public methods of the library are documented in-code. For detailed examples check out attached demo project.

## License

Code in this project is available under the MIT license.

## Credits

The library is using concepts from:

- [KEZCollectionViewTableLayout by ketzusaka](https://github.com/ketzusaka/KEZCollectionViewTableLayout)

