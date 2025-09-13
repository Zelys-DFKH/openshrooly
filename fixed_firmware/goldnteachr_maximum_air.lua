-- File: goldnteachr_maximum_air.lua
-- MAXIMUM AIR CIRCULATION VERSION: Golden Teacher with 98% fan duty cycle
-- For severe mold problems - fan runs almost continuously
-- Only 12 seconds rest every 10 minutes (98% duty cycle)

println("Starting execution of: goldnteachr_maximum_air.lua")

-- Pod name and version information reported --
mushroomID    = "g-t-p"     -- Keep same ID as original to maintain menu compatibility
mushroomName  = "GoldnTeachr"
recipeVersion = 4  -- Version 4: Maximum air circulation
luaAPIVersion = 1

set_recipe_version(recipeVersion)
set_mushroom_name(mushroomName)
set_mushroom_id(mushroomID)
---------------------------------------------

-----------------Constants-------------------
white_led_brightness             = 70         -- unit: percentage - WHITE LEDs
blue_led_intensity               = 80         -- unit: percentage - BLUE LEDs
photoperiod                      = 12         -- unit: hours
fan_cycle_period                 = 600        -- unit: seconds (10 minutes)
---------------------------------------------

-----------------Variables-------------------
sunrise                          = 6          -- in hours (6:00 AM)
deadline_epoch                   = get_start_epoch() + 86400  -- Example: 1 day after start

-- MAXIMUM AIR CIRCULATION - 98% duty cycle (588 seconds ON / 12 seconds OFF per 10-minute cycle)
-- Only one brief 12-second rest period per 10 minutes
fan_phases                       = {60, 60, 60, 60, 60, 60, 60, 60, 60, 48, 12}  -- 11 phases: 10 active + 1 tiny rest
fan_speeds                       = {55, 65, 75, 85, 90, 85, 75, 65, 70, 80, 0}   -- Varying speeds for air circulation, last is brief rest

-- Function to convert specific datetime to epoch
function datetime_to_epoch(year, month, day, hour, min, sec)
    return os.time{year=year, month=month, day=day, hour=hour, min=min, sec=sec}
end

-- Tim-controlled start epoch (set to a specific datetime)
tim_control_start_epoch = datetime_to_epoch(2024, 10, 31, 10, 00, 00)
---------------------------------------------

-----------------Functions-------------------

function adjust_target_rh(current_temp)
    -- With maximum air circulation, we can reduce humidity targets more aggressively
    -- This helps prevent mold while maintaining adequate moisture for pinning
    if current_temp < 75 then
        return 90  -- Reduced from 95% due to continuous high air flow
    else
        return 86  -- Further reduced for warmer temps with maximum circulation
    end
end

-- LIGHTING CONTROL - Same as previous versions
function control_lighting(current_epoch)
    local current_hour = tonumber(os.date("%H", current_epoch))
    local current_minute = tonumber(os.date("%M", current_epoch))
    local current_second = tonumber(os.date("%S", current_epoch))

    local elapsed_seconds_today = current_second + (60 * current_minute) + (3600 * current_hour)

    local sunrise_seconds = sunrise * 60 * 60
    local sunset_seconds = sunrise_seconds + (photoperiod * 60 * 60)

    if ((sunrise_seconds <= elapsed_seconds_today) and (elapsed_seconds_today < sunset_seconds)) then
        println("(control_lighting) MAXIMUM AIR PINNING - White LEDs: ", white_led_brightness, "%, BLUE LEDs: ", blue_led_intensity, "%")

        -- Activate BOTH white and blue LEDs during photoperiod
        set_white_led_percentage(white_led_brightness)
        set_rgb_color(0, 0, blue_led_intensity)  -- BLUE LIGHT ON for pinning!

    else
        println("(control_lighting) DARK PERIOD - All LEDs OFF for rest cycle")
        set_white_led_percentage(0)
        set_rgb_color(0, 0, 0)  -- Turn off RGB during dark period
    end
end

-- MAXIMUM AIR CIRCULATION - 98% duty cycle for extreme mold prevention
function control_fan(current_epoch)
    local phase_time = current_epoch % fan_cycle_period
    local elapsed_time = 0

    for i = 1, #fan_phases do
        elapsed_time = elapsed_time + fan_phases[i]
        if phase_time < elapsed_time then
            local speed = fan_speeds[i]
            if speed == 0 then
                println("(control_fan) MAXIMUM AIR - Minimal rest phase ", i, ", Time: ", phase_time, " - Fan OFF (12s only)")
            else
                println("(control_fan) MAXIMUM AIR - Active phase ", i, ", Time: ", phase_time, " - Fan at ", speed, "% (nearly continuous)")
            end
            set_fan_percentage(speed)
            return
        end
    end

    -- Failsafe - maximum air circulation means never let fan stop for long
    println("(control_fan) MAXIMUM AIR FAILSAFE - Maintaining 75% fan speed continuously")
    set_fan_percentage(75)  -- Strong continuous air movement
end

function control_humidity(current_epoch)
    local current_rh = get_humidity()
    local current_temp = get_temperature()
    local adjusted_target_rh = adjust_target_rh(current_temp)

    println("(control_humidity) MAXIMUM AIR GT - Current RH: ", current_rh, ", target RH: ", adjusted_target_rh, " (temp: ", current_temp, ") - Maximum air circulation mode")

    -- With maximum air circulation, we need to be more aggressive with humidification
    -- but also more careful to not over-humidify and create mold conditions
    if current_rh < (adjusted_target_rh - 2) then  -- Allow slightly wider tolerance
        println("(control_humidity) RH significantly below target, turning on humidifier")
        set_humidifier(1)
    elseif current_rh < adjusted_target_rh then
        println("(control_humidity) RH slightly below target, humidifier on (gentle)")
        set_humidifier(1)
    else
        println("(control_humidity) RH at target or above, humidifier off (preventing over-saturation)")
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
control_fan(current_epoch)  -- 98% duty cycle maximum air circulation
control_humidity(current_epoch)

println("GoldnTeachr MAXIMUM AIR pinning program completed, next run in 1000 ms")
println("MAXIMUM AIR FEATURES: 98% fan duty cycle (588s ON / 12s OFF per 10min cycle)")
println("EXTREME MOLD PREVENTION: Nearly continuous air movement, reduced humidity targets, optimized for severe mold conditions")