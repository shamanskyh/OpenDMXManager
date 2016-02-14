# OpenDMXManager
OpenDMXManager is a singleton class designed to allow communication with the [EntTec Open DMX](www.enttec.com/open_dmx_usb) interface.

##Installation
Be sure to add the FTDI folder (containing the `ftd2xx.cfg`, `ftd2xx.h`, `libftd2xx.1.2.2.dylib`, and `WinTypes.h` files) to your Xcode project.

You may also need to add a Copy Files phase to your Build Phases to copy the .dylib framework as shown below:
![](http://i65.tinypic.com/esvocl.png)


##Usage
###Objective-C
- OpenDMXManager acts a singleton class. Begin by opening the port:
`[[DMXManager sharedManager] openDMXDevice];`

- Then, send a DMX packet (represented as an array of 512 or fewer `unsigned chars`, with the first byte in the array representing address 1, the second representing address 2, etc.):
`[[DMXManager sharedManager] sendDMXPacket:packet ofLength:512];`

- Close the port by calling `[[DMXManager sharedManager] closeDMXDevice];`
- All functions return a `BOOL` indicating success or failure.

###Swift
- OpenDMXManager acts a singleton class. Begin by opening the port:
`DMXManager.sharedManager().openDMXDevice()`

- Then, send a DMX packet (represented as an array of 512 or fewer `UInt8`s, with the first byte in the array representing address 1, the second representing address 2, etc.):
`DMXManager.sharedManager().sendDMXPacket(&dmxArray, ofLength: 512)`

- Close the port by calling `DMXManager.sharedManager().closeDMXDevice()`
- All functions return a `Bool` indicating success or failure.


##Mavericks and El Capitan
You may need to install an additional FTDI driver that prevents OS X from claiming the device as a serial port. [More information can be found here](http://www.ftdichip.com/Drivers/D2XX/MacOSX/ReadMe-mac.rtf). [The D2xxHelper driver can be found here](http://www.ftdichip.com/Drivers/D2XX/MacOSX/D2xxHelper_v2.0.0.pkg). 


##Acknowledgements
OpenDMXManager was written following a helpful answer [found here](http://stackoverflow.com/questions/14035084/ftdi-communication-with-usb-device-objective-c) about communication with an FTDI device using Objective-C.