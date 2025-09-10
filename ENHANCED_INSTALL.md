# Enhanced OpenShrooly Installation Guide

## Prerequisites
1. ESPHome installed (https://esphome.io/guides/installing_esphome.html)
2. Python 3.9+ 
3. Your Shrooly device connected via USB

## Step 1: Install ESPHome
```bash
pip install esphome
```

## Step 2: Prepare Configuration
1. Copy `enhanced_openshrooly.yaml` to your ESPHome directory
2. Update WiFi credentials in the YAML file:
   ```yaml
   wifi:
     ssid: "YourWiFiNetworkName"
     password: "YourWiFiPassword"
   ```

## Step 3: Pin Configuration Check
The YAML assumes standard ESP32-S3 pins. You may need to adjust these based on your Shrooly hardware:

**Display Pins:**
- CS: GPIO 5
- DC: GPIO 17  
- BUSY: GPIO 4
- RESET: GPIO 16

**Button Pins:**
- Left: GPIO 0
- Left-Center: GPIO 35
- Right-Center: GPIO 32
- Right: GPIO 33

**Control Pins:**
- Fan: GPIO 25
- Humidifier: GPIO 26
- White LEDs: GPIO 27
- RGB Red: GPIO 14
- RGB Green: GPIO 13
- RGB Blue: GPIO 12

## Step 4: Compile and Flash
```bash
# Compile the firmware
esphome compile enhanced_openshrooly.yaml

# Flash to device (put device in download mode first)
esphome upload enhanced_openshrooly.yaml
```

## Step 5: First Boot
1. Device will create WiFi hotspot "Enhanced-OpenShrooly" (password: "openshrooly")
2. Connect and configure your WiFi
3. Device will reboot and connect to your network
4. Access web interface at device IP address

## Step 6: Test Menu System
1. **Left/Right buttons**: Navigate between programs
2. **Left-Center button**: Select current program  
3. **Right button**: Start/Stop selected program
4. **Display**: Shows current program and environment status

## Available Programs
- **Golden Teacher Pinning**: 70% white + blue LEDs, high humidity
- **Golden Teacher Fruiting**: 100% white + blue LEDs, optimized for fruiting
- **Oyster**: Standard oyster mushroom parameters
- **Reishi**: Standard reishi mushroom parameters

## Customization
Edit the YAML file to:
- Add more mushroom programs
- Adjust LED intensities and colors
- Modify fan speeds and humidity levels
- Change button mappings
- Customize display layout

## Troubleshooting

**Display not working:**
- Check SPI pin connections
- Verify display model in YAML (currently set to waveshare 2.13in-ttgo-b73)
- Increase display buffer allocation if needed

**WiFi connection issues:**
- Double-check SSID/password
- Use 2.4GHz network (ESP32 doesn't support 5GHz)
- Check for special characters in password

**Buttons not responding:**
- Verify GPIO pin numbers match your hardware
- Check pull-up resistor configuration
- Test with multimeter for continuity

**Sensors not reading:**
- Confirm I2C device addresses (SHT3x typically 0x44 or 0x45)
- Check I2C SDA/SCL pin connections
- Enable I2C scanning in logs

## Home Assistant Integration
Once connected to WiFi, the device will automatically appear in Home Assistant (if you have it) as:
- Enhanced OpenShrooly
- All sensors, controls, and programs as individual entities
- Create automations and dashboards for remote monitoring

## Updates
To update firmware:
1. Modify YAML as needed
2. Run: `esphome upload enhanced_openshrooly.yaml`
3. Device will update over-the-air (OTA) via WiFi