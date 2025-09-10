# GoldnTeachr Fixed Firmware - Compilation & Flashing Guide

## 🔧 FIXES APPLIED

1. **Blue Light Fix**: `control_lighting()` now properly activates blue LEDs during photoperiod
2. **Fan Improvement**: 5-minute cycles instead of 15-minute, more active time for pinning

## 📁 Files Created

- `goldnteachr_fixed.lua` - Corrected Lua script with both fixes
- Located in: `/mnt/c/Projects/openshrooly/fixed_firmware/`

## ⚠️ BACKUP FIRST

**CRITICAL**: Backup your current working firmware before flashing!

```bash
cd /mnt/c/Games/esptool
# Backup current firmware
python esptool.py --chip esp32s3 --port COM[X] read_flash 0x0 0x1000000 shrooly_gt_backup_$(date +%Y%m%d).bin
```

## 🛠️ Compilation Options

### Option 1: Replace Lua Script in Existing Firmware
If you have the original firmware source code:
1. Replace the GoldnTeachr Lua script with `goldnteachr_fixed.lua`
2. Recompile the firmware using your build system
3. Flash the new firmware

### Option 2: Runtime Script Update (If Supported)
Some systems allow runtime Lua script updates:
1. Access web interface
2. Upload new Lua script
3. Restart cultivation program

### Option 3: Manual Web Interface Commands
**Immediate workaround** while waiting for firmware update:

```javascript
// Execute these commands in web interface during light period (6 AM - 6 PM)
set_white_led_percentage(70);
set_rgb_color(0, 0, 80);  // Blue light ON

// For better fan control
set_fan_percentage(60);   // Continuous moderate fan
```

## 📱 Flashing Instructions

### Using esptool.py:

```bash
cd /mnt/c/Games/esptool

# Put device in flash mode (hold BOOT button while pressing RESET)

# Flash new firmware (replace [NEW_FIRMWARE.bin] with actual filename)
python esptool.py --chip esp32s3 --port COM[X] --baud 921600 write_flash 0x0 [NEW_FIRMWARE.bin]

# Reset device after flashing
```

### Using Arduino IDE or Platform IO:
1. Load project with corrected Lua script
2. Select ESP32-S3 board
3. Select correct COM port  
4. Upload firmware

## 🧪 Testing the Fixes

### Blue Light Test:
1. Set time to between 6 AM - 6 PM
2. Verify **both** white (70%) and blue (80%) LEDs are ON
3. Outside light hours: all LEDs should be OFF

### Fan Test:
1. Observe fan cycles - should be more frequent (5-minute cycles)
2. Fan should run for longer periods within each cycle
3. Less silent time between cycles

### Expected Behavior:
- **6 AM - 6 PM**: 70% white LEDs + 80% blue LEDs + variable fan (40-80%)
- **6 PM - 6 AM**: All lights OFF + reduced fan activity

## 🚨 Troubleshooting

### If Blue Light Still Doesn't Work:
1. Check hardware connections (RGB LED strip on GPIO42)
2. Verify power supply to LEDs (5V for WS2812)
3. Use web interface manual commands as backup

### If Fan Issues Persist:
1. Check fan connection (PWM signal on GPIO37)
2. Verify fan power supply (typically 12V)
3. Test with manual fan commands

### Recovery:
If new firmware doesn't work:
```bash
# Restore backup
python esptool.py --chip esp32s3 --port COM[X] write_flash 0x0 shrooly_gt_backup_[DATE].bin
```

## 📊 Key Changes Summary

| Component | Original | Fixed |
|-----------|----------|--------|
| Blue LEDs | Never activated | 80% during photoperiod |
| White LEDs | 70% (working) | 70% (unchanged) |
| Fan Cycles | 15 min (900s) | 5 min (300s) |
| Fan Active Time | 161s/cycle (18%) | 270s/cycle (90%) |
| Photoperiod | 6 AM - 6 PM | 6 AM - 6 PM |

Your Golden Teacher pinning setup should now have proper blue light activation and much better air circulation!