

# About
This supports sharing a monitor and Bluetooth keyboard between 2 Macs.

Many modern Bluetooth keyboards allow you to connect to multiple computers and select the current one via a keyboard shortcut.

For example, I use a version of this [Keychron K1 keyboard](https://www.keychron.com/products/keychron-k1-wireless-mechanical-keyboard) and can use the "fn-1" and "fn-2" key combinations to connect the keyboard to my work or personal Mac.

I have both computers connected to a monitor with multiple inputs.  With bluekvm installed on each computer, whenever I switch the keyboard to a computer it automatically switches the monitor input to that computer as well.

Ideally, you could also switch your Bluetooth mouse (or trackpad) when the keyboard connects too; however I have not been able to get blueutil to do that.  The Mac OS does not let you connect the device to another computer unless you first unpair with the other and I haven't figured out how to do that and then pair automatically with the other.  For now I have two pointer devices and just physically switch them when shifting focus.

# Install
You will need to do this on each computer you want to control.

## Monitor Input Selection
We rely on [ddcctl](https://github.com/kfix/ddcctl) (on Intel Macs) or [m1ddc](https://github.com/waydabber/m1ddc) (on M1 Macs) to switch the active input. Ideally we would have one utility that worked on both flavors of Macs.

## ddcctl
**Only if on Intel hardware:** To install [ddcctl](https://github.com/kfix/ddcctl), just do:
```
brew install ddcctl
```
## m1ddc
**Only if on M1 hardware:** To install [m1ddc](https://github.com/waydabber/m1ddc), just do:
```
brew install m1ddc
```

## blueutil
To monitor Bluetooth connections we will use [blueutil](https://github.com/toy/blueutil).

To install this, just do:

```
brew install blueutil
```

## bluekvm
The logic of this script is very simple -- wait for the specified device (the keyboard) to connect and then switch the monitor input to this computer.

First, determine the MAC address of your keyboard and the choice of input for the computer.

1. List the paired devices:

    ```
    blueutil --paired
    ```

    Find the line for your keyboard and copy the MAC address, e.g.
    
    ```
    address: dc-2c-26-d6-41-d2, connected (slave, -58 dBm), not favourite, paired, name: "K1-keyboard", recent access date: 2020-12-24 17:00:44 +0000
    ```
    
1. Determine the input you want for this computer:

    The most common choices are these:
    
    | Input Source  | Value |
    | ------------- |-------|
    | DisplayPort-1 | 15    |
    | DisplayPort-2 | 16    |
    | HDMI-1        | 17    |
    | HDMI-2        | 18    |
    
    See the full table at [ddcctl](https://github.com/kfix/ddcctl/blob/master/README.md)
    
1. Create a configuration file in `/usr/local/etc/bluekvm.rc`:

    ```
    keyboard=dc-2c-26-d6-41-d2
    display1=18
    ``` 
    Where the keyboard value is copied from the paired keyboard listed by blueutil and the display1 value is selected from the ddcctl table.  If you want a second display to also be switched, add another entry like this: `display2=18`

1. Copy the `bluekvm.sh` script to `/usr/local/bin`:

    ```
    cp bluekvm.sh /usr/local/bin
    ```

1. Test the script:

    Run it manually on each computer and switch your keyboard back and forth to verify the monitor switches inputs appropriately.

    ```
    /usr/local/bin/bluekvm.sh
    ```
    
    Use `ctrl-C` to force it to exit when you are done.
    
1. Install the script as a launch daemon so that it is always running when you are logged in:
    
    ```
    cp bluekvm.plist ~/Library/LaunchAgents/ 
    launchctl load -w ~/Library/LaunchAgents/bluekvm.plist
    ```
    
    Verify that it is running:
    
    ```
    launchctl list bluekvm
    ```
    
    There should be an entry PID in the output, e.g.
    
    ```
    {
    	"LimitLoadToSessionType" = "Aqua";
    	"Label" = "bluekvm";
    	"OnDemand" = false;
    	"LastExitStatus" = 0;
    	"PID" = 31317;
    	"Program" = "/usr/local/bin/bluekvm.sh";
    };
    ```

### Uninstall

To uninstall the `bluekvm.sh` daemon:

```
launchctl unload -w ~/Library/LaunchAgents/bluekvm.plist
rm ~/Library/LaunchAgents/bluekvm.plist
```



### Copyright 2020-2023 Mike Carlton
Released under terms of the MIT License: http://carlton.mit-license.org/
