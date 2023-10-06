--- massiaen v0.1 @fellowfinch
--- llllllll.co/t/url
--- 
--- "birds are the first and
--- the greatest performers"
--- -Messiaen
--- 
--- ▼ instructions below ▼
---  
---
--- E1 change that bird!
--- E2 chirp size
--- E3 chirp volume
---
--- K1 combo
--- K2 it sings
--- K3 it listens (!)
--- K1+K2 toggle garden
--- K1+K3 toggle info
---
---
--- show the bird what you got
--- by playing some shit into 
--- the buffer (press k3). 
--- it listens (!)
--- enough listening! 
--- make it sing by pressing k2.
--- 

--libs 
Lattice = require ("lattice") -- clock for the randomization paterning 
s = require("sequins") -- the sequence at which the randomization changes

--include ("lib/birds") --2sacha: we will add this for the libs yea?

-------- VARIABLES --------

local k1_pressed = false

---table variables
rate = r
duration = d
level = l
pitch_bend = pb

-- bird variables
bird_is_singing = false
bird_voice = 1
bird_level = 0
bird_pan = 0
bird_cutoff = 18000
bird_filter_q = 4
active_bird = 1 -- active bird is strictly a VALUE as it is used in the rand_bird() functions
brd_change = "wren"
active_loop = false

-- forest variables
forest_voice = 6 -- 2sacha: this was changed from 2 to playhead 6
forest_level = 0
forest_is_planted = false
garden_is_planted = false

--info variable
info = false


-- sofutcut varables
is_recording = false
dub_level = 0.3
loop_start = 1
loop_end = loop_start + 0.01
level_slew = 0.2
pan_slew = 0.2
rate_slew = 0.1
fade_time = 0.2
MAX_LOOP = 4 -- max loop length
MAX_BUFFER = 350 -- max length of softcut buffer

pan_aut = false -- might use this later on?

-- UI variables
display_note = false 
display_exl = false
k1_pressed = false
k2_pressed = false
garden = false
info = false

-- transform
transform_party = false

-- clock table for birds
-- this is basically so it can be canceled by calling the function clock.cancel(ids[current_bird]) that is now hooked up to the Toggle of K2
ids = {}
ids["wren"] = clock.run
ids["robin"]= clock.run
ids["trush"] = clock.run
ids["nightingale"] = clock.run
ids["blackbird"] = clock.run
ids["finch"] = clock.run
ids["great tit"] = clock.run
ids["awesomebird"] = clock.run
ids["weird"] = clock.run

-------- TABLES --------

-- bird table
-- here you can add it in the future as it is the current_bird
-- difference between current bird is that current bird looks for a STRING while active_bird looks for a VALUE
birds = {"wren", "robin", "trush", "nightingale", "blackbird", "finch", "great tit"}

-- sequins 
pat1_div_seq = s{1/1,1/1} -- how quickly will the bird change, currently the only one active
-- pat2_div_seq = s{1/4,1/8,1/2}
-- pat2_rate_seq = s{4,-4,2,-2,s{4,3,2,1,-1,-2,-3,-4}}

-------- FUNCTIONS --------

-- function for changing the bird
  -- the function looks for the argument "brd_name" so it looks what arguments occupies and then changes it to that argument
function change_bird(brd_name)
  if brd_name == "wren" then
    current_bird = "wren"
    active_bird = 1
  elseif brd_name == "robin" then
    current_bird = "robin"
      active_bird = 2
    elseif brd_name == "trush" then
    current_bird = "trush"
      active_bird = 3
    elseif brd_name == "nightingale" then
    current_bird = "nightingale"
      active_bird = 4
    elseif brd_name == "blackbird" then
    current_bird = "blackbird"
      active_bird = 5
    elseif brd_name == "finch" then
    current_bird = "finch"
      active_bird = 6
    elseif brd_name == "great tit" then
    current_bird = "great tit"
      active_bird = 7
  end
  dirtyscreen = true
end

-- load forest file
function load_audio(path)
  if path ~= "cancel" and path ~= "" then
    local ch, len = audio.file_info(path)
    if ch > 0 and len > 0 then
      --filename_forest = path
      softcut.buffer_clear_channel(2)
      softcut.buffer_read_mono(path, 0, 1, -1, 1, 2, 0, 1)
      --softcut.buffer_read_mono(file, start_src, start_dst, dur, ch_src, ch_dst)
      local l = math.min(len / 48000, MAX_BUFFER) -- 2sacha: can you explain this to me please, why 48000? because of the sample rate?
      -- plant forest
      softcut.loop_start(forest_voice, 1)
      softcut.loop_end(forest_voice, 1 + l)
      params:set("plant_forest", 2) -- set forest to yes when loading -> automatically toggles playback
      print("file loaded: "..path.." is "..l.."s")
    else
      print("not a sound file")
    end
  end
end

-- forest
function toggle_forest()
  if forest_is_planted then
    softcut.position(forest_voice, 1)
    softcut.play(forest_voice, 1)
    softcut.level(forest_voice, forest_level)
  else
    softcut.level(forest_voice, 0)
  end
end

-- garden
-- 2sacha: garden mode basically should put the listener in a space where the sampled audio is then populated to different playheads based on the chosen birds via params
function toggle_garden()
  if garden_is_planted then
  garden = true
  populate()
  else
  garden = false
  dirtyscreen = true
  end
end


function populate() -- 2sacha: populate function should make a copy of the signal and throw it into different 5 playheads, the recorded material would then intermingle...i'll explain better on the sesh 
    -- Initialize stage
    print ("they are coming")
    softcut.buffer_clear()
    if bird_is_singing and active_loop then
      clock.cancel(ids[current_bird])
    -- Set up the softcut playheads (5)
    for i = 1, 5 do 
        softcut.enable(i, 1)
        softcut.buffer(i, 1)
        softcut.level(i, 0)
        softcut.rate(i, 1.0)
        softcut.loop(i, 1)
        softcut.loop_start(i, 1)
        softcut.loop_end(i, 5)
        softcut.position(i, 1)
        softcut.play(i, 1)
        softcut.fade_time(i, fade_time)
        
        -- Slew
        softcut.level_slew_time(i, level_slew)
        softcut.pan_slew_time(i, pan_slew)
        softcut.rate_slew_time(i, rate_slew)
        
        -- Pan
        softcut.pan(i, bird_pan)
        
        -- Filter
        softcut.post_filter_dry(i, 0)
        softcut.post_filter_lp(i, 1)
        softcut.post_filter_fc(i, bird_cutoff)
        softcut.post_filter_rq(i, bird_filter_q)
        
        -- Get the selected bird from params
        local chosenBirdIndex = params:get("choir") -- this will need work!
        local chosenBird = birds[chosenBirdIndex]
        print("Chosen Bird: " .. chosenBird .. sc.buffer)
        end
    end
end

function toggle_active_loop() -- this is so we can hear what we recorded
  --2sacha: i want this so we can hear what we recorded without needing to activate the bird, this is done via params "seed audiable?" option
  if active_loop then
    bird_is_singing = not bird_is_singing
    softcut.play(bird_voice, 1)
    softcut.level(bird_voice, bird_level)
  else
    softcut.level(bird_voice, 0)
  end
end

-- set loop points
function set_loop()
  local s = params:get("loop_start")
  local l = params:get("loop_size")
  -- set and clamp loop start
  loop_start = util.clamp(s, 0, MAX_LOOP - l)
  if loop_start >= MAX_LOOP - l then
    params:set("loop_start", MAX_LOOP - l)
  end
  -- set and clamp loop end
  local size = loop_end - loop_start
  loop_end = util.clamp(loop_start + l, loop_start + 0.01, MAX_LOOP)
  if loop_end >= MAX_LOOP then
    params:set("loop_start", MAX_LOOP - size)
  end
  -- set softcut
  softcut.loop_start(bird_voice, loop_start + 1)
  softcut.loop_end(bird_voice, loop_end + 1)
  -- debug
  print("Loop size:", size)
  print("Loop start:", loop_start)
  print("Loop end:", loop_end)
end

--bird level
function set_bird_level()
  if bird_is_singing then
    softcut.level(bird_voice, bird_level)
  else
    softcut.level(bird_voice, 0)
  end
end

-- init function
function init()
  softcut.buffer_clear()
  softcut.enable(bird_voice, 1) 
  softcut.buffer(bird_voice, 1) 
  softcut.level(bird_voice, 0)
  softcut.rate(bird_voice, 1.0)
  softcut.loop(bird_voice, 1)
  softcut.loop_start(bird_voice, 1)
  softcut.loop_end(bird_voice, 5)
  softcut.position(bird_voice, 1)
  softcut.play(bird_voice, 1)
  softcut.fade_time(bird_voice, fade_time)
  -- slew
  softcut.level_slew_time(bird_voice, level_slew)
  softcut.pan_slew_time(bird_voice, pan_slew)
  softcut.rate_slew_time(bird_voice, rate_slew)
  -- pan
  softcut.pan(bird_voice, bird_pan)
  -- filter
  softcut.post_filter_dry(bird_voice, 0)
  softcut.post_filter_lp(bird_voice, 1)
  softcut.post_filter_fc(bird_voice, bird_cutoff)
  softcut.post_filter_rq(bird_voice, bird_filter_q)
  -- audio routings
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  audio.level_tape_cut(0)
  softcut.level_input_cut(1, bird_voice, 1.0)
  softcut.level_input_cut(2, bird_voice, 1.0)
  -- softcut recording
  softcut.rec_level(bird_voice, 0)
  softcut.pre_level(bird_voice, 1)
  softcut.rec(bird_voice, 1)
  -- forest playback
  softcut.enable(forest_voice, 1) 
  softcut.buffer(forest_voice, 2)
  softcut.level(forest_voice, 0.1)
  softcut.rate(forest_voice, 1)
  softcut.loop(forest_voice, 1)
  softcut.loop_start(forest_voice, 0)
  softcut.loop_end(forest_voice, MAX_BUFFER)
  softcut.position(forest_voice, 1)
  softcut.play(forest_voice, 0)
  softcut.fade_time(forest_voice, 2)
  
  --other init
  init_lattice()
  --lat:start()
  

  -- PARAMETERS
  -- bird voice params
  params:add_separator("bird_voicing", "bird voice")
  
  params:add_option("chosen_bird", "chosen bird", birds, active_bird)
  params:set_action("chosen_bird", function (val) change_bird(active_bird) brd_change = birds[val] dirtyscreen = true end)

  params:add_control("bird_level", "level", controlspec.new(0, 1, 'lin', 0, 0, ""))
  params:set_action("bird_level", function(val) bird_level = val set_bird_level() dirtyscreen = true end)

  params:add_control("bird_pan", "pan", controlspec.new(-1, 1, 'lin', 0, 0, ""))
  params:set_action("bird_pan", function(val) bird_pan = val softcut.pan(bird_voice, val) end)

  params:add_control("cutoff", "cutoff", controlspec.new(20, 20000, 'exp', 0, 17000, "Hz"))
  params:set_action("cutoff", function(x) softcut.post_filter_fc(bird_voice, x) end)

  -- set loop
  params:add_separator("chirp_material", "chirp material")

  params:add_option("loop_active", "seed audiable?", {"no", "yes"}, 1)
  params:set_action("loop_active", function(val) active_loop = val == 2 and true or false toggle_active_loop() end)

  params:add_control("loop_start", "loop start", controlspec.new(0, MAX_LOOP - 0.01, 'lin', 0.01, 0, "s"))
  params:set_action("loop_start", function() set_loop() dirtyscreen = true end)

  params:add_control("loop_size", "loop size", controlspec.new(0.01, MAX_LOOP, 'lin', 0.01, 0.01, "s"))
  params:set_action("loop_size", function() set_loop() end)

  -- transform
  params:add_separator("transform birds")
  
  params:add_option("transform", "start the party?", {"no", "yes"}, 1)
  params:set_action("transform", function(val) transform_party = val == 2 and true or false transform() end)
  
  -- create garden
  params:add_separator("garden")
  params:add_group("choir", "bird choir", 5)
  for i = 1, 5 do
    params:add_option("choir", "friendly visitor "..i, birds, active_bird, 1)
  end
   params:add_option("summon_birds", "attract?", {"no", "yes"}, 1)
   params:set_action("summon_birds", function(val) garden_is_planted = val == 2 and true or false toggle_garden() end)
  
  -- add forest
  params:add_separator("forest_params", "plant forest or garden")
  params:add_file("load_forest", "> load enviroment", "")
  params:set_action("load_forest", function(path) load_audio(path) end)

  params:add_option("plant_forest", "plant?", {"no", "yes"}, 1)
  params:set_action("plant_forest", function(val) forest_is_planted = val == 2 and true or false toggle_forest() end)

  params:add_control("forest_level", "level", controlspec.new(0, 1, 'lin', 0, 1, ""))
  params:set_action("forest_level", function(val) forest_level = val softcut.level(forest_voice, val) end)
  
  params:bang()

  -- metros
  screenredrawtimer = metro.init(function() screen_redraw() end, 1/15, -1)
  screenredrawtimer:start()

end

-------- UTILITIES --------
function screen_redraw()
  if dirtyscreen then
    redraw()
    dirtyscreen = false
  end
end


-- BIRDS
-- Bird song transcription with duration -- // bird tables can be broken out into a lib.

--NIGHTING GALE
gale_1 = {
  {r = 1, d = 0.20},--eight
  {r = 12, d = 0.83},--half  
  {r = 7, d = 0.10}, --sixteen  
  {r = 8, d = 0.20}, 
  {r = 1, d = 0.20},
  {r = 12, d =  0.83},
  {r = 7, d = 0.10},
  {r = 8, d = 0.10},
  {r = 10, d = 0.83},
  {r = (1)/2, d = 0.20}
}

--EUROPEAN ROBIN
robin_1 = {
  {r = 19, d = 0.105},
  {r = 17, d = 0.105},
  {r = 14, d = 0.105},
  {r = 12, d = 0.105},
  {r = 9, d = 0.105},
  {r = 7, d = 0.105},
  {r = 5, d = 0.105},
  {r = 2, d = 0.105},
  {r = 1, d = 0.215},
}
robin_2 = {
  {r = 14, d = 0.105},
  {r = 12, d = 0.435},
}
robin_3 = {
  {r = 1, d = 0.215},
}

--EUROASIAN WREN
wren_1 = {
  {r = 6, d = 0.18},   
  {r = 3, d = 0.18},   
  {r = 1, d = 0.18},   
  {r = 11, d = 0.36}, }
wren_2 = {
  {r = 3, d = 0.18},
  {r = 1, d = 0.18},
  {r = 11, d = 0.36},
  {r = 1, d = 0.18},
  {r = 2, d = 0.004},
  {r = 1, d = 0.09}, }
wren_3 = {  
  {r = 1.5, d = 0.09},
  {r = 1, d = 0.09},
  {r = 1.5, d = 0.09},
  {r = 1, d = 0.09},
  {r = 1.5, d = 0.09},
  {r = 1, d = 0.09},
  {r = 1.5, d = 0.09},
  {r = 1, d = 0.09},
  {r = 1.5, d = 0.09},
  {r = 1, d = 0.09},
  {r = 1.5, d = 0.09},
  {r = 1, d = 0.09},
  {r = 1.5, d = 0.09},
  {r = 1, d = 0.09},
  {r = 1.5, d = 0.09},
  {r = 5, d = 0.36},
  {r = 6, d = 0.18},}
wren_4 ={  
  {r = 11, d = 0.18},
  {r = 1, d = 0.18}, 
  {r = 11, d = 0.18},
  {r = 1, d = 0.18}, 
  {r = 11, d = 0.18},
  {r = 1, d = 0.18}, 
  {r = 11, d = 0.18},
  {r = 1, d = 0.18}, 
  {r = 11, d = 0.18},
  {r = 1, d = 0.18}, 
  {r = 11, d = 0.18},
  {r = 1, d = 0.36},
  {r = (1)/2, d = 0.36}
}
--SONG TRUSH
trush_1 = {
  {r = 10, d = 0.05}, --grace note
  {r = 4, d = 0.1},  --sixteenth
  {r = 13, d = 0.05},
  {r = 7, d = 0.1},
  {r = 15, d = 0.1},
}
trush_2 = {
  {r = 10, d = 0.05}, --grace note
  {r = 4, d = 0.1},  --sixteenth
  {r = 13, d = 0.05},
  {r = 7, d = 0.1},
  {r = 15, d = 0.1},
}
trush_3 = {
  {r = 7, d = 0.05},  --32th
  {r = 8, d = 0.05},
  {r = 14, d = 0.05},
  {r = 13, d = 0.05},
  {r = 12, d = 0.05},
  {r = 10, d = 0.05},
  {r = 9, d = 0.1},
}
trush_4 = {
  {r = 1, d = 0.05},  --32th
  {r = 7, d = 0.05},
  {r = 13, d = 0.05},
  {r = 14, d = 0.05},
  {r = 14, d = 0.1},
  {r = 1, d = 0.05},  --32th
  {r = 7, d = 0.05},
  {r = 13, d = 0.05},
  {r = 14, d = 0.05},
  {r = 14, d = 0.1},
}
trush_5 ={
  {r = 1, d = 0.1}
}

--COMMON finch
finch_1 = {
  {r = 18, d = 0.025},
  {r = 0, d = 0.008},
  {r = 18, d = 0.025},
  {r = 0, d = 0.011},
  {r = 17, d = 0.020},
  {r = 0, d = 0.002},
  {r = 17, d = 0.015},
  {r = 0, d = 0.002},
  {r = 17, d = 0.012},
  {r = 0, d = 0.002},
  {r = 17, d = 0.010},
  {r = 0, d = 0.002},
  {r = 17, d = 0.050},
  {r = 12, d = 0.025},
  {r = 19, d = 0.025},
  {r = 0, d = 0.040},
  {r = 11, d = 0.020},
  {r = 0, d = 0.002},
  {r = 10, d = 0.015},
  {r = 0, d = 0.002},
  {r = 9, d = 0.012},
  {r = 0, d = 0.002},
  {r = 10, d = 0.020},
  {r = 0, d = 0.020},
  {r = 9, d = 0.025},
  {r = 0, d = 0.020},
  {r = 8, d = 0.030},
  {r = 7, d = 0.020},
  {r = 0, d = 0.020},
  {r = 1.5, d = 0.045},
}

  
--BLACKBIRD
blackbird_1 = {
  {r = (11) + 12 , d = 0.052},--32
  {r = (11) + 12 , d = 0.052},
  {r = (11) + 12 , d = 0.052},
  {r = 4, d = 0.052},
  {r = (9) + 12 , d = 0.052},
  {r = (11) + 12 , d = 0.052},
  {r = 3, d = 0.052},
  {r = (9) + 12 , d = 0.052},
  {r = (13) + 12 , d = 0.052},
  {r = (10) + 12 , d = 0.052},
  {r = 1 , d = 0.052},}
blackbird_2 = {  
  {r = 1 , d = 0.208},--eight
  {r = (15) + 12 , d = 0.052},--eight
  {r = (17) + 12 , d = 0.052},
  {r = (13) + 12 , d = 0.104}
}
blackbird_3 = {  
  {r = 1 , d = 0.208}
}--eight
blackbird_4 = {
--[[    {r = 11, d = 0.052, pb = 0},
    {r = 11, d = 0.052, pb = 5},
    {r = 11 , d = 0.052, pb = 0.5},
    {r = 4, d = 0.052},]]
    {r = (9) + 12 , d = 0.052, pb = 0},
    {r = (11) + 12 , d = 0.052, pb = 0.3},
    {r = 3, d = 0.052},
    {r = (9) + 12 , d = 0.052, pb = 0},
    {r = (13) + 12 , d = 0.052, pb = 0.2},
    {r = (10) + 12 , d = 0.052, pb = 0},
    {r = 1 , d = 0.052, pb = 1},}


--GREAT TIT --- 
great_tit_1 = {
  {r = (6) + 12 , d = 0.52},--32
  {r = (1) + 12 , d = 0.52},
  {r = (6) + 12 , d = 0.52},
  {r = (1.2) + 12 , d = 0.52},
  {r = (6) + 12 , d = 0.52},
  {r = (6) + 12 , d = 0.52},
}
great_tit_2 = {
  {r = (6) + 12 , d = 0.52},--32
  {r = 0 , d = 0.025}, --small pause
  {r = (1.1) + 12 , d = 0.52},
  {r = 0 , d = 0.025}, --small pause
  {r = (6) + 12 , d = 0.52},
  {r = 0 , d = 0.025}, --small pause
  {r = (1.3) + 12 , d = 0.52},
  {r = 0 , d = 0.025}, --small pause
  {r = (6.1) + 12 , d = 0.52},
  {r = 0 , d = 0.25}, -- long pause
  {r = (6) + 12 , d = 0.52},
}
great_tit_3 = {
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.25}, -- long pause
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.025}, --small pause
  {r = (9) + 12 , d = 0.25},--32
  {r = 0 , d = 0.025}, --small pause
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.025}, --small pause
  {r = (9) + 12 , d = 0.25},--32
  {r = 0 , d = 0.025}, --small pause
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.025}, --small pause
  {r = (9) + 12 , d = 0.25},--32
  {r = 0 , d = 0.025}, --small pause
  {r = (6) + 12 , d = 0.25},
  {r = 0 , d = 0.25}, -- long pause
  {r = (6) + 12 , d = 0.25},--32
  {r = 0 , d = 0.025}, --small pause
  {r = (9) + 12 , d = 0.25},--32
}

--AWESOME BIRD
-- should behave based on scale
awesome_1 = {
    {r = 1, d = 1/8},
    {r = 7, d = 1/16},   
    {r = 12, d = 1/8},   
    {r = 1, d = 1/8}, 
    {r = 12, d = 1/4},
  }
  awesome_2 = {
    {r = 7, d = 1/8},
    {r = 1, d = 1/16},   
    {r = 12, d = 1/8},   
    {r = 4, d = 1/8}, 
    {r = 1, d = 1/4}
  }
  awesome_3 = {
    {r = 7, d = 1/32},
    {r = 1, d = 1/16},   
    {r = 7, d = 1/32},   
    {r = 12, d = 1/8}, 
    {r = 1, d = 1/4},
    {r = 7, d = 1/2},
    {r = 12, d = 1/16},
    {r = 4, d = 1/16},
    {r = 7, d = 1/24},
    {r = 12, d = 1/32},
    {r = 4, d = 1/8},
    {r = 1, d = 1/4},
  }
  awesome_4 = {
    {r = 1, d = 1/32},
    {r = 2, d = 1/32},   
    {r = 4, d = 1/32},   
    {r = 5, d = 1/32}, 
    {r = 7, d = 1/32},
    {r = 9, d = 1/32},
    {r = 11, d = 1/32},
    {r = 12, d = 1/32},
    {r = 1, d = 1/4},
    {r = 12, d = 1/32},
    {r = 11, d = 1/32},
    {r = 9, d = 1/32},
    {r = 7, d = 1/16},
    {r = 5, d = 1/8}, 
    {r = 4, d = 1/4},
    {r = 2, d = 1/2}, 
    {r = 1, d = 1/1},
  }
  awesome_5 = {
    {r = 1, d = 1/8},
    {r = 7, d = 1/16},   
    {r = 1, d = 1/8},   
    {r = 7, d = 1/8}, 
    {r = 12, d = 1/4}
  }
  
  --WEIRD BIRD
  -- should behave based on scale
  weird = {
    {r = math.random((12)+2 / 2), d = 1/4},
    {r = math.random((24)+2 / 2), d = 1/4},   
    {r = math.random((7)+3*2), d = 1/4},   
    {r = math.random((24)+2 / 2), d = 1/4}, 
    {r = math.random((12)+2 / 2), d = 1/4},
  }
  
-------- OTHER FUNCTIONS -------

--auto pan
function pan_aut()
  if pan_aut == not pan_aut then
    for i = 1,#robin_song() do
      softcut.pan(1,math.random(2))
    end
  end
end


-- 12TET
function ntor(n)
  return math.pow(2, n / 12)
end

-- Pause
function pause()
  if display_note then
    display_note = false
    dirtyscreen = true
  end
  softcut.level(1, 0)
  clock.sleep(math.random(1) + 0.2)
  softcut.level(bird_voice, bird_level)
  print("pause")
  display_note = true
  dirtyscreen = true
end

--long pause
function pause_l()
  if display_note then
    display_note = false
    dirtyscreen = true
  end
  softcut.level(1, 0)
  clock.sleep(250)
  softcut.level(bird_voice, bird_level)
  print("pause")
end

--Playback atmo garden or forest
function atmo(play)
  if play then
    softcut.play(2,1)
  else
    softcut.play(2,0)
  end
end

function toggle_rec()
  if is_recording then
    softcut.rec_level(1, 1)
    softcut.pre_level(1, dub_level)
    display_note = false
    display_exl = true
  else
    softcut.rec_level(1, 0)
    softcut.pre_level(1, 1)
    display_note = false
    display_exl = false
  end
  dirtyscreen = true
end

-- play note functions, just so it plays notes from a given table
function play_notes2(table)
    for i = 1, #table do
      local current_note = table[i]
      local rate = ntor(current_note.rate) * 3
      softcut.rate(1, rate)
      clock.sleep(current_note.duration)
      --print(i)
    end
end


---------------TESTING AREA-----------
--2sacha: this is a testing area to fine tune the birdsong

-- great_tit TEST

gt_1 = {
  {r = 0, d = 0.2, l = 0, pb = 0.1},
  {r = 6, d = 0.13, l = 0.5, pb = 0},
  {r = 0, d = 0.02, l = 0},
  {r = 1, d = 0.18, l = 0.7, pb = 0},
  {r = 0, d = 0.2, l = 0},
  {r = 6, d = 0.13, l = 0.5, pb = 0},
  {r = 0, d = 0.02, l = 0},
  {r = 1, d = 0.18, l = 0.7, pb = 0},
  {r = 0, d = 0.2, l = 0},
  
}

function play_notes(note_table)
    for i = 1, #note_table do
      local current_note = note_table[i]
      local rate = ntor(current_note.r) * 3
      softcut.rate(1, rate)
      
     
      softcut.level(1, current_note.l or bird_level)
      
      if current_note.pb then
        local pitch_bend = current_note.pb
        if pitch_bend ~= 0 then
          local target_rate = pitch_bend
          
          softcut.rate_slew_time(1, target_rate)
        end
      end
      
      clock.sleep(current_note.d)
    end
end

  
-----------------------------------


--RANDOMS SEQUENCE for birds
--randomize function -- currently just for wren
-- 2sacha: i think we'll need to find a way of making it random for all birds
function generate_random_sequence()
  local sequence = {wren_1, wren_2, wren_3, wren_4}
  for i = 1, #sequence do -- loop throught the elements
    local random_index = math.random(i) -- picks a random number
    sequence[i], sequence[random_index] = sequence[random_index], sequence[i] -- swaping the current element with random positions
  end
  return sequence -- give us the sequense
end

--BIRD FUNCTIONS! 
function wren_song()
  while true do
  softcut.level(bird_voice, bird_level)
  local sequence = generate_random_sequence()
    for i = 1, #sequence do
     play_notes(sequence[i])
     pause()
    end
  end
--pause_l()
end

function wren_song_2()
  while true do
    softcut.level(bird_voice, bird_level)
    play_notes(wren_1)
    print ("wren_song")
    pause()
    play_notes(wren_2)
    print ("wren_song")
    pause()
    play_notes(wren_3)
    print ("wren_song")
    pause()
    play_notes(wren_4)
    print ("wren_song")
    --pause_l()
  end
end

function robin_song()
  while true do
    softcut.level(bird_voice, bird_level)
    print ("robin_song")
    play_notes(robin_1)
    pause()
    print ("robin_song")
    play_notes(robin_2)
    pause()
    print ("robin_song")
    play_notes(robin_3)
    pause()
  end
end

function trush_song()
  while true do
  softcut.level(bird_voice, bird_level)
  play_notes(trush_1)
  pause()
  play_notes(trush_2)
  pause()
  play_notes(trush_3)
  pause()
  play_notes(trush_4)
  pause()
  play_notes(trush_5)
  pause()
  end
end

function finch_song()
  while true do
    softcut.level(bird_voice, bird_level)
  play_notes(finch_1)
  pause()
  end
end

function blackbird_song()
  while true do
    softcut.level(bird_voice, bird_level)
    play_notes(blackbird_1)
    pause()
    play_notes(blackbird_2)
    pause()
    play_notes(blackbird_3)
    pause()
   play_notes(blackbird_4)
  pause()
  end
end

function nightingale_song()
  while true do
  softcut.level(bird_voice, bird_level)
  play_notes(gale_1)
  pause_l()
  end
end

function great_tit_song()
  while true do
  softcut.level(bird_voice, bird_level)
  --[[play_notes(great_tit_1)
  pause()
  play_notes(great_tit_2)
  pause()
  play_notes(great_tit_3)]]
  play_notes(gt_1)
  pause()
  end
end

function great_tit_song2()
  while true do
  softcut.level(bird_voice, bird_level)
  play_notes(great_tit_1)
  pause()
  play_notes(great_tit_2)
  pause()
  play_notes(great_tit_3)
  pause()
  end
end


--other birds
function awesomebird_song()
  while true do
  softcut.level(bird_voice, bird_level)
  play_notes(awesome_1)
  pause()
  play_notes(awesome_2)
  pause()
  play_notes(awesome_3)
  pause()
  play_notes(awesome_4)
  pause()
  play_notes(awesome_5)
  --pause_l()
  end
end

function weird_song()
  while true do
play_notes(weird)
  pause()
  end
end


-------- UI --------

-- ENCODERS
function enc(n, d)
  if n == 1 then
    active_bird = util.clamp(active_bird + d, 1, #birds)
    params:set("chosen_bird", active_bird)
  elseif n == 2 then
    params:delta("loop_start", d / 10)
  elseif n == 3 then
    params:delta("bird_level", d / 10)
  end
  dirtyscreen = true
end

-- KEYS
-- TOGGLES HERE
function key(n, z)
   if n == 1 and z == 1 then
    garden_is_planted = not garden_is_planted
    garden = not garden
    info = not info
    k1_pressed = not k1_pressed
   elseif k1_pressed and n == 2 and z == 1 then
     k1_pressed = true
     garden = true
     print ("garden = true")
     info = false
     print ("info = false")
     dirtyscreen = true
   elseif n == 2 and z == 1 then
    k1_pressed = false
    garden = false
    info = false
    bird_is_singing = not bird_is_singing
    active_loop = not active_loop

    if bird_is_singing and active_loop and k1_pressed == false then
      print("play")
      if current_bird == "wren" then
        ids["wren"] = clock.run(wren_song)
      elseif current_bird == "robin" then
        ids["robin"] = clock.run(robin_song)
      elseif current_bird == "trush" then
        ids["trush"] = clock.run(trush_song)
      elseif current_bird == "finch" then
        ids["finch"] = clock.run(finch_song)
      elseif current_bird == "blackbird" then
        ids["blackbird"] = clock.run(blackbird_song)
      elseif current_bird == "great tit" then
        ids["great tit"] = clock.run(great_tit_song)
      elseif current_bird == "nightingale" then
        ids["nightingale"] = clock.run(nightingale_song)
      elseif current_bird == "awesomebird" then
        ids["awesomebird"] = clock.run(awesome_song)
        --clock.run(awesomebird_song)
      elseif current_bird == "weird" then
        id["weird"] = clock.run(weird_bird)
      end
      display_note = true
      display_exl = false
    else
      softcut.level(bird_voice, 0)
      clock.cancel(ids[current_bird])
      display_note = false
      print("cancel")
      dirtyscreen = true
    end
    dirtyscreen = true
  elseif n == 3 and z == 1 then
    --if k1_pressed and k2_pressed then
      --softcut.buffer_clear_channel(1) -- don't clear both buffers but only buffer 1
    if k1_pressed and n == 3 and z == 1 then
      k1_pressed = true
      info = true
      garden = false
      dirtyscreen = true
    else
      k1_pressed = false
      info = false
      garden = false
      is_recording = not is_recording
      toggle_rec()
    end
  end
end

function info_here()
  if info == true then
   display_note = false
   display_exl = false
  end
  dirtyscreen = true
 end

-- GUI
function redraw()
  screen.clear()
  screen.move(10, 50)
  screen.font_face(1)
  screen.font_size(8)
  screen.text("pos: ")
  screen.move(118, 50)
  screen.text_right(params:string("loop_start"))
  screen.move(10, 60)
  screen.text("volume: ")
  screen.move(118, 60)
  screen.text_right(params:string("bird_level"))
  
   if brd_change == "weird" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/weird1.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("weird boi")
    current_bird = "weird"
  elseif brd_change == "awesomebird" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/awesome1.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("good boi")
    current_bird = "awesomebird"
  elseif brd_change =="great tit" then
    if info == true then
      display_note = false
      display_exl = false
      screen.clear()
      screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/great_tit_info.png", 0, 0)
      screen.move(50,9)
      screen.font_size(11)
      screen.font_face(15)
      screen.text("great")
      screen.move(50,21)
      screen.text("tit")
      screen.move(50,30)
      screen.font_size(8)
      screen.font_face(1)
      screen.text("blessed with a big")
      screen.move(50,40)
      screen.text("repertoire, yet is")
      screen.move(0,50)
      screen.text("most known for it's signature")
      screen.move(0,60)
      screen.text("couplets of sweet tee-cher!")
    elseif info == false then  
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/great_tit.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("great tit")
    current_bird = "great tit"
    end
  elseif brd_change =="finch" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/chaffinch.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("chaffinch")
    current_bird = "finch"
  elseif brd_change == "trush" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/trush1.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("song thrush")
    current_bird = "trush"
  elseif brd_change == "robin" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/robin1.png", 38, 20)
    screen.move(65, 10)
    screen.text_center("european robin")
    current_bird = "robin"
  elseif brd_change =="nightingale" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/gale1.png", 38, 20)
    screen.move(65, 10)
    screen.text_center("nightingale")
    current_bird = "nightingale"
  elseif brd_change == "blackbird" then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/blackbird1.png", 38, 18)
    screen.move(65, 10)
    screen.text_center("euroasian blackbird")
    current_bird = "blackbird"
  elseif brd_change == "wren" then --- this is new use it at every brd change!
    if info == true then
      display_note = false
      display_exl = false
      screen.clear()
      print("you are talking to wren")
      screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/wren_info.png", 0, 0)
      screen.move(50,10)
      screen.font_size(11)
      screen.font_face(15)
      screen.text("euroasian")
      screen.move(50,20)
      screen.text("wren")
      screen.move(50,30)
      screen.font_size(8)
      screen.font_face(1)
      screen.text("although small")
      screen.move(50,40)
      screen.text("in size the wren")
      screen.move(0,50)
      screen.text("is loud. full of trills and long")
      screen.move(0,60)
      screen.text("verses with rapid-fire bursts.")
    elseif info == false then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/wren1.png", 38, 20)
    screen.move(65, 10)
    screen.text_center("euroasian wren")
    current_bird = "wren"
    end
  end
  if display_note then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/note.png", 90, 20)
  end
  if display_exl then
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/exl.png", 90, 20)
  end
  if garden == true then
    print("this should change")
    screen.clear()
    screen.display_png(_path.code .. "/massiaen/assets/brd_pngs/garden2.png", 0, 0)
  elseif garden == false then
    brd_change = current_bird
  end
  if info == true then
    print("I will showcase info")
  elseif info == false then
    brd_change = current_bird
  end
  screen.update()
  print(current_bird)
end

-- TRANSFORM ---- TRANSFORM --
-- random function meant transform the bird ndomly changing the birds 
-- active_bird is a variable and therefore the math.random is searching for these variables for the lenght of the birds table (#birds)
-- brd_change is a variable that starts with our default bird (wren) and then is based on whatever the next active_bird is 
-- this is then used in the redraw function and the encoder function

function transform() -- this will be the TRANSFORM funciton
  if transform_party == true then
    lat:start() -- starts the sequence
    rand_bird() -- calls for a function
  elseif transform_party == false then
    lat:stop()
    clock.cancel(active_bird)
  end
end

function rand_bird()
    active_bird = math.random(#birds) -- randomly changes the variable of active_bird
    brd_change = birds[active_bird]  -- corresponds the current_bird to the active_bird variable
    
    rando() -- calls for a function where it starts the clock based on current bird
    change_bird() -- calls for a function where it connects active_bird,current_bird to bird_name
    
    dirtyscreen = true
end

function rando()
  if current_bird == "wren" then
        active_bird = 1
        ids["wren"] = clock.run(wren_song)
        display_note = true
        display_exl = false
        
  --[[--elseif current_bird ~= "wren" then
        clock.cancel(active_bird)
        print ("wren CANCEL")]] -------trying to solve the canceling of clocks!
      
  elseif current_bird == "robin" then
        active_bird = 6
        ids["robin"] = clock.run(robin_song)
        display_note = true
        display_exl = false
        
--[[--elseif current_bird ~= "robin" and active_bird ~= 6 then
      clock.cancel(active_bird + 6)
      print ("robin CANCEL")]]
    
      elseif current_bird == "trush" then
        ids["trush"] = clock.run(trush_song)
        display_note = true
        display_exl = false
      elseif current_bird == "finch" then
        ids["finch"] = clock.run(finch_song)
        display_note = true
        display_exl = false
      elseif current_bird == "great tit" then
        ids["great tit"] = clock.run(great_tit_song)
        display_note = true
        display_exl = false  
      elseif current_bird == "blackbird" then
        ids["blackbird"] = clock.run(blackbird_song)
        display_note = true
        display_exl = false
      print ("blackbird CANCEL")
      elseif current_bird == "nightingale" then
         ids["nightingale"] = clock.run(nightingale_song)
        display_note = true
        display_exl = false
    end
end


function cancel_all() -- stops the sequence and clocks
  clock.cancel(active_bird)
  lat:stop()
end
    
  -- LATTICE 
  -- function to start the lattice occupied by one sprocket which calls for the function rand_bird() and sets the division of change
  function init_lattice()
    lat = Lattice:new{
      auto = true, --its a master clock
      meter = 4,
      ppqn = 96 -- pusles per quarter note
    }
  
    random_bird_time = lat:new_sprocket{
      action = function(t) 
       rand_bird() 
       random_bird_time:set_division(pat1_div_seq())
      end,
      division = 1,
      enabled = true
    }
  end
  
------------------------------------------------------------------------------------------

--[[
--- proof of concept
--clock.run(play_birdsongs, bird.robin)

function play_birdsongs(bird)

  local songcount = 0
  while true do
    softcut.level(1, volume)
    local song = math.random(1, #bird)
    -- play notes
    for i = 1, #bird[song] do
      local current_note = bird[song][i]
      local rate = ntor(current_note.rate) * 3
      softcut.rate(1, rate)
      clock.sleep(current_note.duration)
    end
    softcut.level(1, 0)
    clock.sleep(math.random(1) + 0.2)
  end
end

bird = {}
bird.robin = {}
for i = 1, 3 do
  bird.robin[i] = {}
end

bird.robin[1] = {
  {rate = 19, duration = 0.105},
  {rate = 17, duration = 0.105},
  {rate = 14, duration = 0.105},
  {rate = 12, duration = 0.105},
  {rate = 9, duration = 0.105},
  {rate = 7, duration = 0.105},
  {rate = 5, duration = 0.105},
  {rate = 2, duration = 0.105},
  {rate = 1, duration = 0.215},
}

bird.robin[2] = {
  {rate = 14, duration = 0.105},
  {rate = 12, duration = 0.435},
}

bird.robin[3] = {
  {rate = 1, duration = 0.215},
}

]]
