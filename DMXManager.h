//
//  DMXManager.h
//  OpenDMXManager
//
//  Created by Harry Shamansky on 2/11/16.
//  Copyright © 2016 Harry Shamansky. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMXManager : NSObject

+ (instancetype)sharedManager;

/// Opens the DMX Device
/// @return a boolean success value
- (BOOL)openDMXDevice;

/// Closes the DMX Device
/// @return a boolean success value
- (BOOL)closeDMXDevice;

/// Writes a DMX packet to the DMX device.
/// @param packet: An array of 512 bytes representing one universe of DMX data.
/// @return a boolean success value
- (BOOL)sendDMXPacket:(unsigned char *)packet ofLength:(unsigned int)length;

@end

NS_ASSUME_NONNULL_END