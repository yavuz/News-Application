# News Application Documentation
[![License](http://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

## Overview

Written by Obj-C

Application provides users to be able to read and share newspapers, news resources, websites etc. With the use of feed,rss and xml. If you wish you can easily customize the interface and even you can add you own listings.

Application will be ready and working easily by following the steps on the documentation. Admob integration is ready to use. If you wish you can activate the admob and start publishing advertisements.

For the further details please check on the screenshots or the presentation video.

Of course, you can use this application if your WordPress site's RSS support. You can news applicaiton or an application running with a single RSS in iTunes.

For example app: [Australian Papers](https://itunes.apple.com/tr/app/australian-papers/id716039893)

[Video Tutorial](https://www.youtube.com/watch?v=vSceEUBAK08)

## Features

* User friendly interface
* Highly customizable
* Changeable content
* Fast ready state
* Offline cacheable
* Image caching and async view
* News can be readable inside the application
* iOS 7/8 and resizable compatibility. Ipad, iphone etc.
* Switching with swipe functions between news
* News sharing
* Color theming
* Easily changing the application language with one language file
* Unlimited rss and xml links can be added
* Any font can be used for the interface
* Single Page(RSS)

## Usage

It is very easy to make the application work. 

Ready the following files are required. You can edit according to your wishes. Then you can run the application immediately.

[1. Newssources.plist - Add a news source](#add-a-news-source-newssourcesplist)
[2. Settings.plist - Application settings](#application-settings-settingsplist)
[3. Settings.plist - Single RSS](#single-rss-settingsplist)
[4. Localizable.strings - Language File](#localizablestrings-language-file)

### Add a news source - Newssources.plist

Add news sources will need to add a row. rss,xml etc. Your application sources list.

![enter image description here](http://www.yavuzyildirim.com/newsappdoc/assets/images/newssources.png)

Example item keys;

* [Name] - Source Name
* [SubName] - Source sub name
* [IconName] - Favicon on main screen
* [Url] - Source Url
* [MainPageView] - Do you want view in mainscreen?
* [MainPageOrder] - Mainscreen order
Source you can write to this file as you want.


### Application settings - Settings.plist

Your application settings file. You may want to change a few things in application. For example, fonts or Admob(Ads service). You can make these settings from this file.

![enter image description here](http://www.yavuzyildirim.com/newsappdoc/assets/images/settings.png)

Example key descriptions;   

* [APPFONTNAME] - Regular Font of Application
* [APPBOLDFONTNAME] - Bold Font of Application
* [ADMOBVIEW] - Do you have Admob advertising view? if yes, value TRUE. if no, value FALSE
* [ADMOBKEY] - Your application Admob Key. You will receive this key AdMob service.
* [ITUNESLINK] - Your application in AppStore link. You will receive itunesconnect(Apple Service)

Admob ads service link: <http: www.google.com="" ads="" admob="">


### Single RSS - Settings.plist

If the application you want to run with a single RSS. 'ONEPAGESETTINGS' would be enough to make the settings section. First you need to do as 'OneRSSPage' section, you must do the 'YES'. Then, 'Item0' You need to enter the information you want to write sections.

![enter image description here](http://www.yavuzyildirim.com/newsappdoc/assets/images/singlerss.png)

Example key descriptions;   

* [OneRSSPage] - Single RSS state
* [Item0] - Single Page Information
    * [Name] - Source Name
    * [SubName] - Source sub name
    * [IconName] - Favicon on main screen
    * [Url] - Source Url

  
When we do these settings 'Newssources.plist' file will be left out.  
If you do not want something like that 'NO', you must do.

## Localizable.strings - Language File

This file is language file. English is default. If you want to change, open the file and you must enter the corresponding words.

Example;

    "DescReadNews" = "Click To Read";

to

    "DescReadNews" = "Read Now";

## License

This library is licensed under the [MIT License](LICENSE).