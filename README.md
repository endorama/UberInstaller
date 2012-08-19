# UberInstaller

UberInstaller is a python script which aims to automatize software installation on a fresh installation of a linux distro.

## 1. How It Works

UberInstaller base his processing upon a JSON file in which are specified all packages to be installed, and upon some convention needed to make the use of the script more intuitive possible.

Before and after performing the installation is possible to execute two scripts ( `pre_cmds` and `post_cmds`, see 1.3 ), written in any language, that will be executed by the host machine respecting the shebang at the beginning of the file.

### 1.1 JSON configuration file

The JSON file must be a **valid JSON file** ( will be processed with Python default JSON library ), but **can** contain comments, because before passing to the parser, UberInstaller strips all comments and whitespaces from the JSON file.

This is an example of JSON file:

```json
{
  // meta is required!
  "meta": {
    "version"           : "precise",      // OS version in which you can find all the specified packages/repository
    "arch"              : "32"            // 32bit or 64bit specific package file
  },
  // packages is required, can contain an unlimited number of package definition
  "packages": {
    "Sublime Text 2": {
      "pkg": [ "sublime-text-2" ],
      "ppa": "ppa:webupd8team/sublime-text-2"
    },
    "ZSH": {
      "pkg": [ "zsh" ],
    },
    "Oh My ZSH": {
      "cmd": {
        "before": [ "mv ~/.zshrc ~/.zshrc.orig " ]
      },
      "cvs": {
        "folder": "~/.oh-my-zsh",
        "url": "git://github.com/robbyrussell/oh-my-zsh.git"
      },
      "type": "git"
    },
    "Wine": {
      "pkg": "wine1.3_1.3.28-0ubuntu1~ppa1~natty1_i386.deb",
      "type": "offline"
    },
  }
}
```

This file will be used by UberInstaller to install Sublime Text 2 from Sublime repository ( which will be automatically added ), ZSH shell ( from Precise repository ), Oh My ZSH ( installed using Git ) and Wine from a dep package.

#### 1.2 Package definition

These are settings available for any single package definition:

```json
{
  ...
  "Package Name": {
    // Commands to be executed before and/or after package installation
    "cmd"     : {
      // A command to be executed before package installation
      // Type: List of strings
      "before": None,       
      // A command to be executed after package installation
      // Type: List of strings
      "after" : None        
    },
    // If 'git' type is specified these settings are used to perform git clone
    "cvs"     : {          
      // Clone the specified branch instead of repository default
      // Type: String
      "branch": None,      
      // The folder in which clone the repository
      // Type: String
      "folder": "",      
      // The URL of the Git repository
      // Type: String
      "url"   : "",        
    },
    // Depends on 'type' key:
    //   - if 'type' is not specified or 'default':
    //     a list of packages to be installed
    //   - if 'type' is 'git':
    //     this key is ignored, use 'cvs' instead
    //   - if 'type' is 'offline':
    //     name of the package to be installed, as string ( package path is calculated automatically, see 1.3 )
    //     Only file with .bin, .deb or .run extension will be processed
    // Type: List | None | String
    "pkg"     : [  ],      
    // Does the package require a extra ppa? Specify it here ( "ppa:you-ppa/name" )
    // Type: String
    "ppa"     : None,      
    // Does the package require a extra repository? ( must begin with 'http://' )
    // [ never put OS VERSION! at least if you don't really need it! ]
    // Type: String
    "repo"    : None,      
    // Do you want to skip this package? Set it to True
    // Type: Boolean
    "skip"    : False,     
    // Installation type. Could be 'default' ( use apt-get ), 'offline' ( use a local file ), 'git' ( clone a git repository )
    // Type: String
    "type"    : "default", 
    // Specific version to be installed of the package to be installed
    // NOT YET SUPPORTED
    // Type: String
    "version" : None       
  },
  ...
}
```

### 1.3 Local packages path, before and after scripts, log path

UberInstaller used some conventions to define path used by the script.

To run the script you must specify a path to the JSON configuration file. That path is used to determine all others path.

All local packages must be inside a `pkgs` subfolder in the same folder of the JSON file.
The `pre_cmds` and `post_cmds` files must be located in the same folder of the JSON file.

Example:

    sudo uberinstaller /home/user/uberinstaller/precise.json

    local packages path: /home/user/uberinstaller/pkgs
    pre_cmds script    : /home/user/uberinstaller/pre_cmds
    post_cmds script   : /home/user/uberinstaller/post_cmds

## 2 ToDo

- make possible to import custom/self defined repository keys

## 3 Test

UberInstaller was developed under Ubuntu 11.10 Oneiric Ocelot, used under Ubuntu 12.04 Precise Pangolin and tested under both Oneiric and Precise.

## 4 Contributing

1. Make you own fork
2. Create a branch "feature-branch" ( name must be more self-explanatory possibile )
3. Do your changes! :)
4. Send a pull request on 'develop' branch
5. Enjoy! ^^

## 5 FAQ

* > I have some content in a zip files, how can I install it?

  As UberInstaller is capable of handling only single file in offline processing, could be a little cucumbersome to understand how to install custom packages or files which are not .bin, .deb, or .run.

  For example, I'd like to install a theme for Unity/Gnome Shell. Themes are packaged in zip files, which are not processed by UberInstaller. The easiest solution is to build a .run file using [Makeself](http://megastep.org/makeself/), which can create self-extracting tar.gz archives from folder. Have a look at the documentation, is dead simple and is much more flexible than any other way I found.
