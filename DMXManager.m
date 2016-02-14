//
//  DMXManager.m
//  OpenDMXManager
//
//  Created by Harry Shamansky on 2/11/16.
//  Copyright © 2016 Harry Shamansky. All rights reserved.
//

#import "DMXManager.h"
#import "ftd2xx.h"

#define INT2VOIDP(i) (void*)(uintptr_t)(i)

@implementation DMXManager {
    FT_HANDLE dmxDevice;
    __block FT_STATUS ftdiPortStatus;
}

+ (instancetype)sharedManager {
    static DMXManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DMXManager alloc] init];
    });
    return sharedManager;
}

- (BOOL)openDMXDevice {
    
    DWORD numDevs = 0;
    
    // Grab the number of attached devices
    ftdiPortStatus = FT_ListDevices(&numDevs, NULL, FT_LIST_NUMBER_ONLY);
    
    dmxDevice = NULL;
    
    if (ftdiPortStatus != FT_OK) {
        NSLog(@"Electronics error: Unable to list devices");
        return NO;
    }
    
    if (numDevs == 0) {
        NSLog(@"Unable to find any FTDI devices.");
        return NO;
    }
    
    // Find the device number of the electronics
    for (int currentDevice = 0; currentDevice < numDevs; currentDevice++) {
        char buffer[64];
        
        ftdiPortStatus = FT_ListDevices(INT2VOIDP(currentDevice),buffer,FT_LIST_BY_INDEX|FT_OPEN_BY_DESCRIPTION);
        
        NSString *portDescription = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
        
        if ([portDescription isEqualToString:@"FT232R USB UART"]) {
            
            // Open the communication with the USB device
            ftdiPortStatus = FT_OpenEx("FT232R USB UART",FT_OPEN_BY_DESCRIPTION,&dmxDevice);
            if (ftdiPortStatus != FT_OK) {
                NSLog(@"Electronics error: Can't open USB relay device: %d", (int)ftdiPortStatus);
                return NO;
            }
            //Turn off bit bang mode
            ftdiPortStatus = FT_SetBitMode(dmxDevice, 0x00,0);
            if (ftdiPortStatus != FT_OK) {
                NSLog(@"Electronics error: Can't set bit bang mode");
                return NO;
            }
            // Reset the device
            ftdiPortStatus = FT_ResetDevice(dmxDevice);
            // Purge transmit and receive buffers
            ftdiPortStatus = FT_Purge(dmxDevice, FT_PURGE_RX | FT_PURGE_TX);
            // Set the baud rate
            ftdiPortStatus = FT_SetBaudRate(dmxDevice, 250000);
            // 1 s timeouts on read / write
            ftdiPortStatus = FT_SetTimeouts(dmxDevice, 1000, 1000);
            // Set to communicate at 8N2
            ftdiPortStatus = FT_SetDataCharacteristics(dmxDevice, FT_BITS_8, FT_STOP_BITS_2, FT_PARITY_NONE); // 8N2
            // Disable hardware / software flow control
            ftdiPortStatus = FT_SetFlowControl(dmxDevice, FT_FLOW_NONE, 0, 0);
            // Set the latency of the receive buffer way down (2 ms) to facilitate speedy transmission
            ftdiPortStatus = FT_SetLatencyTimer(dmxDevice,2);
            if (ftdiPortStatus != FT_OK) {
                NSLog(@"Electronics error: Can't set latency timer");
                return NO;
            }
        }
    }
    return ftdiPortStatus == FT_OK;
}

- (BOOL)closeDMXDevice {
    ftdiPortStatus = FT_Close(dmxDevice);
    dmxDevice = 0;
    return ftdiPortStatus == FT_OK;
}

- (BOOL)sendDMXPacket:(unsigned char *)packet ofLength:(unsigned int)length {
    
    // error checking
    if (length > 512) {
        NSLog(@"DMX Packet too large. Maximum size for packet is 512 bytes.");
        return NO;
    }
    if (ftdiPortStatus != FT_OK || dmxDevice == 0) {
        NSLog(@"Error finding DMX device.");
        return NO;
    }
    
    // convert NSArray to primitive
    unsigned char startCode[1] = { 0x00 };
    
    // Toggle the BREAK condition (not sure why this is necessary...)
    FT_SetBreakOn(dmxDevice);
    FT_SetBreakOff(dmxDevice);
    
    DWORD bytesWrittenOrRead;
    
    ftdiPortStatus = FT_Write(dmxDevice, startCode, 1, &bytesWrittenOrRead);
    ftdiPortStatus = FT_Write(dmxDevice, packet, (DWORD)length, &bytesWrittenOrRead);
    
    if (bytesWrittenOrRead < length || ftdiPortStatus != FT_OK) {
        NSLog(@"Bytes written: %d, should be:%d, error: %d", bytesWrittenOrRead, length, ftdiPortStatus);
        return NO;
    }
    return YES;
}

@end
