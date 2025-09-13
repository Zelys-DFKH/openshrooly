# Anti-Mold Golden Teacher Firmware Flashing Guide

## 🚨 Device Connection Issue

Currently COM6 is not responding. To proceed with flashing:

### 1. **Put Device in Bootloader Mode:**
   - **Hold BOOT button** (keep holding)
   - **Press and release RESET button** (while holding BOOT)
   - **Release BOOT button** after 2 seconds
   - LED should dim or change pattern indicating bootloader mode

### 2. **Try Connection Test:**
```bash
cd /mnt/c/Games/esptool
./esptool.exe --chip esp32s3 --port COM6 chip-id
```

### 3. **Backup Current Firmware:**
```bash
cd /mnt/c/Games/esptool
./esptool.exe --chip esp32s3 --port COM6 read_flash 0x0 0x1000000 shrooly_gt_FINAL_FIX_backup_$(date +%Y%m%d_%H%M).bin
```

## 🔧 **CREATED ANTI-MOLD SOLUTIONS:**

### Option 1: Modified Lua Scripts (Ready to Use)
- **File:** `/fixed_firmware/goldnteachr_anti_mold.lua`
- **Fan Duty Cycle:** 95% (570s ON / 30s OFF per 10-minute cycle)
- **Fan Speeds:** 50-85% varying patterns
- **Humidity:** Reduced to 93%/89% (from 95%/92%)

### Option 2: Maximum Air Version (For Severe Mold)
- **File:** `/fixed_firmware/goldnteachr_maximum_air.lua`
- **Fan Duty Cycle:** 98% (588s ON / 12s OFF per 10-minute cycle)
- **Fan Speeds:** 55-90% varying patterns
- **Humidity:** Further reduced to 90%/86%

### Option 3: ESPHome Configuration (Future Use)
- **File:** `/esphome/anti_mold_simple.yaml`
- **Advanced cycling with 95% duty cycle**
- **Can be compiled when ESPHome setup is complete**

## ⚡ **IMMEDIATE WORKAROUND (If Device is Running)**

If your device is currently running and you can access the web interface:

### Manual Commands to Run via Web Interface:
```javascript
// Access device IP in browser, then run these commands:

// For continuous high fan operation:
setInterval(() => {
  const time = Date.now() / 1000;
  const cycle = time % 600; // 10-minute cycles

  if (cycle < 570) {
    // 95% of time - fan running
    const speed = 55 + 30 * Math.sin(cycle / 100); // Varies 55-85%
    fetch('/api/fan/circulation_fan/turn_on', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({speed: Math.max(55, Math.min(85, speed))})
    });
  } else {
    // 5% of time - brief rest
    fetch('/api/fan/circulation_fan/turn_off', {method: 'POST'});
  }
}, 10000); // Check every 10 seconds
```

## 📱 **FLASHING WHEN DEVICE RESPONDS:**

### Step 1: Flash Anti-Mold Firmware
```bash
cd /mnt/c/Games/esptool

# Put device in bootloader mode first!
# Then flash:
./esptool.exe --chip esp32s3 --port COM6 --baud 921600 write_flash 0x0 [ANTI_MOLD_FIRMWARE.bin]
```

### Step 2: If You Have ESPHome Source:
Replace the Golden Teacher Lua script in your firmware source with:
- `goldnteachr_anti_mold.lua` (95% duty cycle - recommended)
- OR `goldnteachr_maximum_air.lua` (98% duty cycle - for severe mold)

Then recompile and flash.

## 🧪 **TESTING THE ANTI-MOLD FIRMWARE:**

After flashing, verify:
1. **Fan Operation:** Should run 95% of the time (9.5 min ON / 0.5 min OFF)
2. **Speed Variation:** Fan speed should vary between 50-85% during active phases
3. **Brief Rest:** Very short 30-second rest periods every 10 minutes
4. **Humidity Adjustment:** Should target 93% RH (instead of 95%)
5. **Blue Light:** Still 80% during photoperiod (6 AM - 6 PM)

## 🆘 **RECOVERY:**

If something goes wrong:
```bash
# Restore original firmware
./esptool.exe --chip esp32s3 --port COM6 write_flash 0x0 shrooly_gt_FINAL_FIX.bin
```

## 📊 **COMPARISON:**

| Version | Fan Duty Cycle | Fan Speeds | Humidity Target | Use Case |
|---------|---------------|------------|-----------------|----------|
| Original | ~80% | 40-80% | 95%/92% | Normal operation |
| Anti-Mold | 95% | 50-85% | 93%/89% | Mild mold issues |
| Maximum Air | 98% | 55-90% | 90%/86% | Severe mold issues |

Your mold problem should be solved with the **Anti-Mold (95%)** version, which provides nearly continuous air circulation while maintaining proper growing conditions for Golden Teacher pinning.