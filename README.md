QTree-objc
==========
Library for location-based clustering of data using [Quadtree](http://en.wikipedia.org/wiki/Quadtree) written in Objective-C.

Suppose you have a lot of items to display on a map.

<table border="0">
  <tr>
    <td>
      You will got a mess if you just add all of them as annotations to the map.
    </td>
    <td>
      It's better to merge items that are close to each other into clusters.
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://raw.github.com/blackm00n/QTree-objc/master/screenshot_no_clusterization.png" alt="No Clusterization Screenshot" width="320" height="568"/>
    </td>
    <td>
      <img src="https://raw.github.com/blackm00n/QTree-objc/master/screenshot_with_clusterization.png" alt="No Clusterization Screenshot" width="320" height="568"/>
    </td>
  </tr>
</table>

Clustering will help you to get a neater map and increase its performance.
QuadTree will help you to get a stable (unlike k-nearest neighbor algorithm) and fast clustering.

Installation
------------
The best approach is to use [CocoaPods](http://cocoapods.org/).

Install CocoaPods gem if it's not installed yet and setup its enviroment:

    $ [sudo] gem install cocoapods
    $ pod setup

Go to the directory containing your project's .xcodeproj file and create Podfile:

    $ cd ~/Projects/MyProject
    $ vim Podfile
  
Add the following lines to Podfile:

```ruby
platform :ios
pod 'QTree-objc'
```
  
Finally install your pod dependencies:

    $ [sudo] pod install
    
That's all, now open just created .xcworkspace file

Usage
-----
You can look at QTreeSample project to see `QTree-objc` in action.

Contact
-------
Aleksey Kozhevnikov
* [blackm00n on GitHub](https://github.com/blackm00n)
* aleksey.kozhevnikov@gmail.com
* [@kozhevnikoff](https://twitter.com/kozhevnikoff)






