-- File: goldnteachr_fixed.lua
-- Fixed GoldnTeachr script with proper blue light and improved fan control
-- This fixes the blue light activation bug and improves fan cycling

println("Starting execution of: goldnteachr_fixed.lua")

-- Pod name and version information reported --
mushroomID    = "g-t-p"
mushroomName  = "GoldnTeachr"
recipeVersion = 2  -- Updated version with fixes
luaAPIVersion = 1

set_recipe_version(recipeVersion)
set_mushroom_name(mushroomName)
set_mushroom_id(mushroomID)
---------------------------------------------

-----------------Constants-------------------
white_led_brightness             = 70         -- unit: percentage - WHITE LEDs
blue_led_intensity               = 80         -- unit: percentage - BLUE LEDs  
photoperiod                      = 12         -- unit: hours
fan_cycle_period                 = 300        -- unit: seconds (5 minutes instead of 15)
---------------------------------------------

-----------------Variables-------------------
sunrise                          = 6          -- in hours (6:00 AM)
deadline_epoch                   = get_start_epoch() + 86400  -- Example: 1 day after start

-- IMPROVED FAN CONTROL - More frequent, gentler cycles for Golden Teacher pinning
fan_phases                       = {30, 30, 30, 30, 90, 30, 30, 30}  -- 8 phases, more active time
fan_speeds                       = {40, 50, 60, 70, 80, 60, 50, 40}   -- Higher speeds for better air exchange

-- Function to convert specific datetime to epoch
function datetime_to_epoch(year, month, day, hour, min, sec)
    return os.time{year=year, month=month, day=day, hour=hour, min=min, sec=sec}
end

-- Tim-controlled start epoch (set to a specific datetime)
tim_control_start_epoch = datetime_to_epoch(2024, 10, 31, 10, 00, 00)  
---------------------------------------------

-----------------Functions-------------------

function adjust_target_rh(current_temp)
    -- Golden Teacher pinning requires high humidity
    if current_temp < 75 then
        return 95  -- Higher humidity for cooler temps during pinning
    else
        return 92  -- Still high but slightly lower for warmer temps
    end
end

-- FIXED LIGHTING CONTROL - Now properly activates blue light!
function control_lighting(current_epoch)
    local current_hour = tonumber(os.date("%H", current_epoch))
    local current_minute = tonumber(os.date("%M", current_epoch))
    local current_second = tonumber(os.date("%S", current_epoch))

    local elapsed_seconds_today = current_second + (60 * current_minute) + (3600 * current_hour)

    local sunrise_seconds = sunrise * 60 * 60
    local sunset_seconds = sunrise_seconds + (photoperiod * 60 * 60)

    if ((sunrise_seconds <= elapsed_seconds_today) and (elapsed_seconds_today < sunset_seconds)) then
        println("(control_lighting) PINNING PHASE - Setting white LEDs to ", white_led_brightness, "% and BLUE LEDs to ", blue_led_intensity, "%")
        
        -- CRITICAL FIX: Activate BOTH white and blue LEDs during photoperiod
        set_white_led_percentage(white_led_brightness)
        set_rgb_color(0, 0, blue_led_intensity)  -- BLUE LIGHT ON for pinning!
        
    else
        println("(control_lighting) DARK PERIOD - Turning off all LEDs for rest cycle")
        set_white_led_percentage(0)
        set_rgb_color(0, 0, 0)  -- Turn off RGB during dark period
    end
end

-- IMPROVED FAN CONTROL - Better for Golden Teacher pinning
function control_fan(current_epoch)
    local phase_time = current_epoch % fan_cycle_period
    local elapsed_time = 0

    for i = 1, #fan_phases do
        elapsed_time = elapsed_time + fan_phases[i]
        if phase_time < elapsed_time then
            println("(control_fan) GT Pinning Phase ", i, ", Time: ", phase_time, " - Setting fan to ", fan_speeds[i], "%")
            set_fan_percentage(fan_speeds[i])
            return
        end
    end

    -- Fallback - should not reach here with proper phase setup
    println("(control_fan) Phase out of bounds - setting moderate fan speed for GT pinning")
    set_fan_percentage(60)  -- Safe fallback for Golden Teacher
end

function control_humidity(current_epoch)
    local current_rh = get_humidity()
    local current_temp = get_temperature()
    local adjusted_target_rh = adjust_target_rh(current_temp)

    println("(control_humidity) GT Pinning - Current RH: ", current_rh, ", target RH: ", adjusted_target_rh, " (temp: ", current_temp, ")")

    if current_rh < adjusted_target_rh then
        println("(control_humidity) RH too low for GT pinning, turning on humidifier")
        set_humidifier(1)
    else
        println("(control_humidity) RH adequate for GT pinning, humidifier off")
        set_humidifier(0)
    end
end
---------------------------------------------

-- Main execution
local start_epoch          = get_start_epoch()
local current_epoch        = get_current_epoch()

set_elapsed_days((current_epoch - start_epoch) / 86400)

-- Execute all control functions
control_lighting(current_epoch)
control_fan(current_epoch)  
control_humidity(current_epoch)

println("GoldnTeachr pinning program completed, next run in 1000 ms")
println("FIXES APPLIED: Blue light now activates during photoperiod, improved fan cycling for pinning phase")