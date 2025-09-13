-- File: goldnteachr_anti_mold.lua
-- ANTI-MOLD VERSION: Golden Teacher with near-continuous fan operation
-- Fan runs 95% duty cycle to prevent mold growth in Golden Teacher pinning
-- Modified from goldnteachr_fixed.lua for maximum air circulation

println("Starting execution of: goldnteachr_anti_mold.lua")

-- Pod name and version information reported --
mushroomID    = "g-t-p"     -- Keep same ID as original to maintain menu compatibility
mushroomName  = "GoldnTeachr"
recipeVersion = 3  -- Version 3: Anti-mold with continuous fan
luaAPIVersion = 1

set_recipe_version(recipeVersion)
set_mushroom_name(mushroomName)
set_mushroom_id(mushroomID)
---------------------------------------------

-----------------Constants-------------------
white_led_brightness             = 70         -- unit: percentage - WHITE LEDs
blue_led_intensity               = 80         -- unit: percentage - BLUE LEDs
photoperiod                      = 12         -- unit: hours
fan_cycle_period                 = 600        -- unit: seconds (10 minutes for longer cycles)
---------------------------------------------

-----------------Variables-------------------
sunrise                          = 6          -- in hours (6:00 AM)
deadline_epoch                   = get_start_epoch() + 86400  -- Example: 1 day after start

-- ANTI-MOLD FAN CONTROL - 95% duty cycle with minimal rest periods
-- Total cycle: 600 seconds (10 minutes)
-- Fan ON: 570 seconds (9.5 minutes) at varying speeds for proper air circulation
-- Fan OFF: 30 seconds (0.5 minutes) for brief rest only
fan_phases                       = {60, 60, 60, 60, 60, 60, 60, 60, 90, 30}  -- 10 phases: 9 active + 1 rest
fan_speeds                       = {50, 60, 70, 80, 85, 80, 70, 60, 75, 0}   -- Higher speeds, last phase is rest

-- Function to convert specific datetime to epoch
function datetime_to_epoch(year, month, day, hour, min, sec)
    return os.time{year=year, month=month, day=day, hour=hour, min=min, sec=sec}
end

-- Tim-controlled start epoch (set to a specific datetime)
tim_control_start_epoch = datetime_to_epoch(2024, 10, 31, 10, 00, 00)
---------------------------------------------

-----------------Functions-------------------

function adjust_target_rh(current_temp)
    -- Golden Teacher pinning requires high humidity, but not so high as to encourage mold
    -- Slightly reduced from original to help prevent mold with increased air circulation
    if current_temp < 75 then
        return 93  -- High humidity but slightly reduced due to continuous air flow
    else
        return 89  -- Lower humidity for warmer temps with continuous circulation
    end
end

-- LIGHTING CONTROL - Same as fixed version with proper blue light activation
function control_lighting(current_epoch)
    local current_hour = tonumber(os.date("%H", current_epoch))
    local current_minute = tonumber(os.date("%M", current_epoch))
    local current_second = tonumber(os.date("%S", current_epoch))

    local elapsed_seconds_today = current_second + (60 * current_minute) + (3600 * current_hour)

    local sunrise_seconds = sunrise * 60 * 60
    local sunset_seconds = sunrise_seconds + (photoperiod * 60 * 60)

    if ((sunrise_seconds <= elapsed_seconds_today) and (elapsed_seconds_today < sunset_seconds)) then
        println("(control_lighting) ANTI-MOLD PINNING - Setting white LEDs to ", white_led_brightness, "% and BLUE LEDs to ", blue_led_intensity, "%")

        -- Activate BOTH white and blue LEDs during photoperiod
        set_white_led_percentage(white_led_brightness)
        set_rgb_color(0, 0, blue_led_intensity)  -- BLUE LIGHT ON for pinning!

    else
        println("(control_lighting) DARK PERIOD - Turning off all LEDs for rest cycle")
        set_white_led_percentage(0)
        set_rgb_color(0, 0, 0)  -- Turn off RGB during dark period
    end
end

-- ANTI-MOLD FAN CONTROL - 95% duty cycle for mold prevention
function control_fan(current_epoch)
    local phase_time = current_epoch % fan_cycle_period
    local elapsed_time = 0

    for i = 1, #fan_phases do
        elapsed_time = elapsed_time + fan_phases[i]
        if phase_time < elapsed_time then
            local speed = fan_speeds[i]
            if speed == 0 then
                println("(control_fan) ANTI-MOLD - Brief rest phase ", i, ", Time: ", phase_time, " - Fan OFF (30s rest)")
            else
                println("(control_fan) ANTI-MOLD - Active phase ", i, ", Time: ", phase_time, " - Setting fan to ", speed, "% (continuous operation)")
            end
            set_fan_percentage(speed)
            return
        end
    end

    -- Failsafe - if something goes wrong, keep fan running at moderate speed
    println("(control_fan) ANTI-MOLD FAILSAFE - Phase calculation error, maintaining 70% fan speed")
    set_fan_percentage(70)  -- Always keep air moving to prevent mold
end

function control_humidity(current_epoch)
    local current_rh = get_humidity()
    local current_temp = get_temperature()
    local adjusted_target_rh = adjust_target_rh(current_temp)

    println("(control_humidity) ANTI-MOLD GT - Current RH: ", current_rh, ", target RH: ", adjusted_target_rh, " (temp: ", current_temp, ") - High air circulation mode")

    if current_rh < adjusted_target_rh then
        println("(control_humidity) RH below target for anti-mold GT pinning, turning on humidifier")
        set_humidifier(1)
    else
        println("(control_humidity) RH adequate for anti-mold GT pinning, humidifier off")
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
control_fan(current_epoch)  -- 95% duty cycle anti-mold operation
control_humidity(current_epoch)

println("GoldnTeachr ANTI-MOLD pinning program completed, next run in 1000 ms")
println("ANTI-MOLD FEATURES: 95% fan duty cycle (570s ON / 30s OFF per 10min cycle), optimized air circulation")
println("MOLD PREVENTION: Continuous air movement with brief rest periods, slightly reduced humidity targets")