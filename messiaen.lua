--- messiaen v0.1 @fellowfinch
--- @sonocircuit
--- llllllll.co/t/url
--- 
--- "birds are the first and
--- the greatest performers"
--- -Messiaen
---        .--.           .--.
---      ."  o \__  __/ .  ".
---  _.-"      /       \.     "-._.
----"         )         (          "_
--- ▼▼▼ instructions below ▼▼▼
---
--- E1 change that bird! 
--- E2 chirp size
--- E3 chirp volume
---
--- K1 combo
--- K2 it sings
--- K3 it listens (!)
--- K1+K2 toggle info
--- K1+K3 toggle garden
---
--- play something for the bird
--- press K3 and the active bird
--- will listen (!)
--- make it sing by pressing k2.
--- 

--libs 
--Lattice = require ("lattice") -- clock for the randomization paterning 
--s = require("sequins") -- the sequence at which the randomization changes

bird = include ("lib/birds")

-------- VARIABLES --------

-- bird variables
NUM_BIRDS = 5
bird_is_singing = false
bird_level = 0
bird_pan = 0
bird_cutoff = 18000
bird_filter_q = 4
active_bird_name = "wren"
active_bird_voice = 1
--tree2tree = true -- for panning

-- seed variables
seed_voice = 2
seed_is_active = true

-- forest variables
forest_voice = 6
forest_level = 0.3
forest_is_planted = true
garden_is_planted = false

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

-- UI variables
display_note = false 
display_exl = false
k1_pressed = false
k2_pressed = false
garden = false
info = false

-- transform
transform_party = false

-- bird clocks
current_bird_clock = nil
garden_bird_clock = {}
for i = 1, NUM_BIRDS do
  garden_bird_clock[i] = nil
end

-- bird tables
bird_tab = {bird.wren, bird.robin, bird.blackbird, bird.chaffinch, bird.g_tit, bird.green_finch, bird.willow_warbler}

-------- FUNCTIONS --------

-- the ultimate ultra super bird clocking function, hell yeah.
function play_birdsongs(bird, voice) --@andy: we need a way of dynamically assigning birds to the softcut voices... 
  local voice = voice or 1 -- ... so if no voice arg is present softcut voice 1 is default
  while true do
    local song = math.random(1, #bird) -- should randomize the bird songs
    -- play notes
    softcut.level(voice, bird_level) -- change dynamically with bird.params[voice].level
    for i = 1, #bird[song] do
      local current_note = bird[song][i]
      local rate = ntor(current_note.r) * 3
      local slew = current_note.pb
      local bird_level = current_note.l
      local fade_time = current_note.ft
      softcut.rate(voice, rate)
      softcut.rate_slew_time(voice, slew)
      softcut.level(voice, bird_level)
      softcut.fade_time(voice, fade_time)
      clock.sleep(current_note.d)
    end
    softcut.level(voice, 0)
    clock.sleep(math.random(1) + 1.2)
  end
end

--[[function tree2tree()
    if bird_is_singing and tree2tree == true then
      bird_pan = math.random(2) + 0.1
      softcut.pan(1, bird_pan)
      print(bird_pan)
  end
end
]]

-- load forest file
function load_audio(path)
  if path ~= "cancel" and path ~= "" then
    local ch, len = audio.file_info(path)
    if ch > 0 and len > 0 then
      --filename_forest = path
      softcut.buffer_clear_channel(2)
      softcut.buffer_read_mono(path, 0, 1, -1, 1, 2, 0, 1)
      --softcut.buffer_read_mono(file, start_src, start_dst, dur, ch_src, ch_dst)
      local l = math.min(len / 48000, MAX_BUFFER)
      softcut.loop_start(forest_voice, 1)
      softcut.loop_end(forest_voice, 1 + l)
      params:set("plant_forest", 2)
      print("file loaded: "..path.." is "..l.."s")
    else
      print("not a sound file")
    end
  end
end

function toggle_forest()
  if forest_is_planted then
    softcut.position(forest_voice, 1)
    softcut.play(forest_voice, 1)
    softcut.level(forest_voice, forest_level)
  else
    softcut.level(forest_voice, 0)
  end
end

function toggle_seed() -- seed audible
  if seed_is_active then
    bird_is_singing = not bird_is_singing
    softcut.play(seed_voice, 1)
    softcut.level(seed_voice, bird_level)
  else
    softcut.level(seed_voice, 0)
  end
end

function toggle_rec()
  if is_recording then
    softcut.rate(1, 1) -- added this in order to always start on rate one when re-recording
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

-- set loop points
function set_loop()
  local s = params:get("bird_loop_start")
  local l = params:get("seed_loop_size")
  -- set and clamp loop start
  loop_start = util.clamp(s, 0, MAX_LOOP - l)
  if loop_start >= MAX_LOOP - l then
    params:set("bird_loop_start", MAX_LOOP - l)
  end
  -- set and clamp loop end
  local size = loop_end - loop_start
  loop_end = util.clamp(loop_start + l, loop_start + 0.01, MAX_LOOP)
  if loop_end >= MAX_LOOP then
    params:set("bird_loop_start", MAX_LOOP - size)
  end
  -- set softcut
  softcut.loop_start(active_bird_voice, loop_start + 1)
  softcut.loop_end(active_bird_voice, loop_end + 1)
end

--bird level
function set_bird_level()
  if bird_is_singing then
    softcut.level(active_bird_voice, bird_level)
  else
    softcut.level(active_bird_voice, 0)
  end
end

-- 12TET
function ntor(n)
  return math.pow(2, n / 12)
end



-- call or change a birdsong
function call_bird(bird_name)
  if current_bird_clock ~= nil then
    clock.cancel(current_bird_clock)
  end
  current_bird_clock = clock.run(play_birdsongs, bird_name)
end

function change_bird(bird_name)
  if bird_is_singing then
    call_bird(bird_name)
  end
end

-- end a birdsong
function stop_bird(voice)
  local voice = voice or 1
  if current_bird_clock ~= nil then
    clock.cancel(current_bird_clock)
  end
  softcut.level(voice, 0)
  softcut.rate(active_bird_voice, 1) -- new
end

-- garden
function toggle_garden()  
  if garden_is_planted then
    params:set("transform", 1) -- turn off transform in case it's running.
    call_garden_birds()
  else
    stop_garden_birds()
  end
end

function call_garden_birds()
  -- cancel active bird if singing
  if current_bird_clock ~= nil then
    clock.cancel(current_bird_clock)
  end
  -- activate birds
  clock.run(function()
    for i = 1, 5 do
      clock.sleep(math.random(2, 8))
      garden_bird_clock[i] = clock.run(play_birdsongs, bird_tab[params:get("friendly_visitor_"..i)], i)
    end
  end)
end

function stop_garden_birds()
  for i = 1, 5 do
    if garden_bird_clock[i] ~= nil then
      clock.cancel(garden_bird_clock[i])
    end
    softcut.level(i, 0)
  end
end

function set_random_bird()
  local val = math.random(#bird.names)
  params:set("chosen_bird", val)
end

function toggle_transform()
  -- TODO
end



---------- init function -----------
function init()
  -- set up softcut for bird voices
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  audio.level_tape_cut(0)
  softcut.buffer_clear()

  for i = 1, NUM_BIRDS do
    softcut.enable(i, 1) 
    softcut.buffer(i, 1) 
    softcut.level(i, 0.6)
    softcut.rate(i, 1.0)
    softcut.loop(i, 1)
    softcut.loop_start(i, 1)
    softcut.loop_end(i, 1 + MAX_LOOP)
    softcut.position(i, 1)
    softcut.play(i, 1)
    softcut.fade_time(i, fade_time)
    -- slew
    softcut.level_slew_time(i, level_slew)
    softcut.pan_slew_time(i, pan_slew)
    softcut.rate_slew_time(i, rate_slew)
    -- pan
    softcut.pan(1, 0)
    softcut.pan(2, 0.5)
    softcut.pan(3, 1)
    softcut.pan(4, -0.5)
    softcut.pan(5, -1)
    softcut.pan(6, 0)
    --changed the panning here /a
    
    -- filter
    softcut.post_filter_dry(i, 0)
    softcut.post_filter_lp(i, 1)
    softcut.post_filter_fc(i, bird.params[i].cutoff)
    softcut.post_filter_rq(i, bird.params[i].filter_q)

    softcut.level_input_cut(1, i, 1.0)
    softcut.level_input_cut(2, i, 1.0)
  end

  -- softcut recording
  softcut.rec_level(active_bird_voice, 0)
  softcut.pre_level(active_bird_voice, 1)
  softcut.rec(active_bird_voice, 1)

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
  
  -- load file
  load_audio("/dust/code/messiaen/assets/forests/robinwren.wav")
    
  -- PARAMETERS
  -- bird voice params
  params:add_separator("bird_voicing", "bird voice")
  
  params:add_option("chosen_bird", "chosen bird", bird.names, 1)
  params:set_action("chosen_bird", function (idx) active_bird_name = bird.names[idx] change_bird(bird_tab[idx]) dirtyscreen = true end)

  params:add_control("bird_level", "level", controlspec.new(0, 1, 'lin', 0, 0.5, ""))
  params:set_action("bird_level", function(val) bird_level = val set_bird_level() dirtyscreen = true end)

  params:add_control("bird_pan", "pan", controlspec.new(-1, 1, 'lin', 0, 0, ""))
  params:set_action("bird_pan", function(val) bird_pan = val softcut.pan(active_bird_voice, val) end)

  params:add_control("cutoff", "cutoff", controlspec.new(20, 20000, 'exp', 0, 17000, "Hz"))
  params:set_action("cutoff", function(x) softcut.post_filter_fc(active_bird_voice, x) end)

  -- set loop
  params:add_separator("chirp_material", "chirp material")

  params:add_option("seed_is_active", "seed audiable?", {"no", "yes"}, 1)
  params:set_action("seed_is_active", function(val) seed_is_active = val == 2 and true or false toggle_seed() end)

  params:add_control("seed_loop_size", "seed loop size", controlspec.new(0.01, MAX_LOOP, 'lin', 0.01, 0.01, "s"))
  params:set_action("seed_loop_size", function() set_loop() end)

  params:add_control("bird_loop_start", "bird voice start", controlspec.new(0, MAX_LOOP - 0.01, 'lin', 0.01, 0, "s"))
  params:set_action("bird_loop_start", function() set_loop() dirtyscreen = true end)

  params:add_control("bird_loop_size", "bird voice size", controlspec.new(0, MAX_LOOP - 0.01, 'lin', 0.01, 0, "s"))
  --params:set_action("bird_loop_size", function() set_loop() dirtyscreen = true end)

  -- transform
  params:add_separator("transform birds")
  
  params:add_option("transform", "start the party?", {"no", "yes"}, 1)
  params:set_action("transform", function(val) transform_party = val == 2 and true or false toggle_transform() end)
  
  -- create garden
  params:add_separator("garden", "garden")
  params:add_group("bird_choir", "bird choir", 5)
  for i = 1, 5 do
    params:add_option("friendly_visitor_"..i, "friendly visitor "..i, bird.names, 1)
  end
   params:add_option("summon_birds", "attract?", {"no", "yes"}, 1)
   params:set_action("summon_birds", function(val) garden_is_planted = val == 2 and true or false toggle_garden() end)
  
  -- add forest
  params:add_separator("forest_params", "plant forest or garden")
  params:add_file("load_forest", "> load enviroment", "")
  params:set_action("load_forest", function(path) load_audio("/home/we/dust/code/messiaen/assets/forests/robinwren.wav") end)

  params:add_option("plant_forest", "plant?", {"no", "yes"}, 2)
  params:set_action("plant_forest", function(val) forest_is_planted = val == 2 and true or false toggle_forest() end)

  params:add_control("forest_level", "level", controlspec.new(0, 1, 'lin', 0, 0.4, ""))
  params:set_action("forest_level", function(val) forest_level = val softcut.level(forest_voice, val) end)
  
  params:bang()

  -- metros
  screenredrawtimer = metro.init(function() screen_redraw() end, 1/15, -1)
  screenredrawtimer:start()

end
  
-------- UI --------

-- ENCODERS
function enc(n, d)
  if garden_is_planted then
    -- maybe the encoders can do fun things while in garden mode?
  else
    if n == 1 then
      params:delta("chosen_bird", d)
    elseif n == 2 then
      params:delta("bird_loop_start", d / 10)
    elseif n == 3 then
      params:delta("bird_level", d / 10)
    end
  end
  dirtyscreen = true
end

-- KEYS
function key(n, z)
  if n == 1 then
    k1_pressed = z == 1 and true or false
  end
  if n == 2 and z == 1 then
    if k1_pressed then
      info = not info
    else
      bird_is_singing = not bird_is_singing
      if bird_is_singing then
        local bird = bird_tab[params:get("chosen_bird")]
        call_bird(bird)
      else
        stop_bird(active_bird_voice)
      end
    end
  elseif n == 3 and z == 1 then
    if k1_pressed then
      garden_is_planted = not garden_is_planted
      toggle_garden()
    else
      is_recording = not is_recording
      toggle_rec()
    end
  end
  dirtyscreen = true
end

function redraw()
  screen.clear()
  if garden_is_planted then
    screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/garden2.png", 0, 0)
  else
    screen.move(10, 50)
    screen.font_size(8)
    screen.text("pos: ")
    screen.move(118, 50)
    screen.text_right(params:string("bird_loop_start"))
    screen.move(10, 60)
    screen.text("volume: ")
    screen.move(118, 60)
    screen.text_right(params:string("bird_level"))

    if bird_is_singing then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/note.png", 90, 20)
    end
    
    if is_recording then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/exl.png", 84, 15)
    end
    
    if active_bird_name == "weird" then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/weird1.png", 38, 18)
      screen.move(65, 10)
      screen.text_center("weird boi")
    elseif active_bird_name == "awesomebird" then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/awesome1.png", 38, 18)
      screen.move(65, 10)
      screen.text_center("good boi")
    elseif active_bird_name =="green finch" then
      if info == true then
        display_note = false
        display_exl = false
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/green_finch_info.png", 0, 0)
        screen.move(50,9)
        screen.font_size(11)
        screen.font_face(15)
        screen.text("green")
        screen.move(50,21)
        screen.text("finch")
        screen.move(50,30)
        screen.font_size(8)
        screen.font_face(1)
        screen.text("this little singer")
        screen.move(50,40)
        screen.text("is characterized")
        screen.move(0,50)
        screen.text("by its melodious mellow trills")
        screen.move(0,60)
        screen.text("and a slow wheeze like dweez.")
      elseif info == false then  
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/green_finch.png", 38, 18)
        screen.move(65, 10)
        screen.text_center("green finch")
      end
    elseif active_bird_name == "willow warbler" then
      if info == true then
        display_note = false
        display_exl = false
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/willow_warbler_info.png", 0, 0)
        screen.move(50,9)
        screen.font_size(11)
        screen.font_face(15)
        screen.text("willow")
        screen.move(50,21)
        screen.text("warbler")
        screen.move(50,30)
        screen.font_size(8)
        screen.font_face(1)
        screen.text("gentle cascades")
        screen.move(50,40)
        screen.text("with a downard")
        screen.move(0,50)
        screen.text("melody and a calm but careful")
        screen.move(0,60)
        screen.text("sounding fragility to its voice.")
      elseif info == false then
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/willow_warbler.png", 38, 18)
        screen.move(65, 10)
        screen.text_center("willow warbler")
      end
--[[    elseif active_bird_name =="nuthach" then
      if info == true then
        display_note = false
        display_exl = false
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/nuthach_info.png", 0, 0)
        screen.move(50,9)
        screen.font_size(11)
        screen.font_face(15)
        screen.text("nuthach")
        screen.move(50,20)
        screen.font_size(8)
        screen.font_face(1)
        screen.text("this neurotic")
        screen.move(50,30)
        screen.text("tree crawler")
        screen.move(50,40)
        screen.text("demands your")
        screen.move(0,50)
        screen.text("attention with loud & liquid")
         screen.move(0,60)
        screen.text("k'wip's and sharp wi-wi-wi's.")
      elseif info == false then
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/nuthach.png", 38, 18)
        screen.move(65, 10)
        screen.text_center("nuthach")
      end]]
    elseif active_bird_name =="great tit" then
      if info == true then
        display_note = false
        display_exl = false
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/great_tit_info.png", 0, 0)
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
        screen.text("most known for its signature")
        screen.move(0,60)
        screen.text("couplets of sweet tee-cher!")
      elseif info == false then  
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/great_tit.png", 38, 18)
        screen.move(65, 10)
        screen.text_center("great tit")
      end
    elseif active_bird_name =="chaffinch" then
      if info == true then
        display_note = false
        display_exl = false
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/chaffinch_info.png", 0, 0)
        screen.move(50,9)
        screen.font_size(11)
        screen.font_face(15)
        screen.text("chaffinch")
        screen.move(50,20)
        screen.font_size(8)
        screen.font_face(1)
        screen.text("jigs and")
        screen.move(50,30)
        screen.text("squibbles with")
        screen.move(50,40)
        screen.text("a downward pull")
        screen.move(0,50)
        screen.text("chaffinch is confident with")
         screen.move(0,60)
        screen.text("its bold & theatrical ending.")
      elseif info == false then
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/chaffinch.png", 38, 18)
        screen.move(65, 10)
        screen.text_center("chaffinch")
      end
--[[    elseif active_bird_name == "trush" then
      if info == true then
        display_note = false
        display_exl = false
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/trush_info.png", 0, 0)
        screen.move(50,9)
        screen.font_size(11)
        screen.font_face(15)
        screen.text("song")
        screen.move(50,21)
        screen.text("trush")
        screen.move(50,30)
        screen.font_size(8)
        screen.font_face(1)
        screen.text("armed with short")
        screen.move(50,40)
        screen.text("song phrases")
        screen.move(0,50)
        screen.text("it repeats them with a trial")
        screen.move(0,60)
        screen.text("and error like strategy.")
      elseif info == false then
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/trush1.png", 38, 18)
        screen.move(65, 10)
        screen.text_center("song thrush")
      end]]
    elseif active_bird_name == "robin" then
      if info == true then
        display_note = false
        display_exl = false
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/robin_info.png", 0, 0)
        screen.move(50,9)
        screen.font_size(11)
        screen.font_face(15)
        screen.text("european")
        screen.move(50,21)
        screen.text("robin")
        screen.move(50,30)
        screen.font_size(8)
        screen.font_face(1)
        screen.text("its scrible and")
        screen.move(50,40)
        screen.text("doodle like")
        screen.move(0,50)
        screen.text("melodies are heard loudly")
        screen.move(0,60)
        screen.text("in the calmness of winter")
      elseif info == false then
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/robin1.png", 38, 20)
        screen.move(65, 10)
        screen.text_center("european robin")
      end
--[[    elseif active_bird_name =="nightingale" then
      if info == true then
        display_note = false
        display_exl = false
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/nightingale_info.png", 0, 0)
        screen.move(50,9)
        screen.font_size(11)
        screen.font_face(15)
        screen.text("nightingale")
        screen.move(50,20)
        screen.font_size(8)
        screen.font_face(1)
        screen.text("heard in the")
        screen.move(50,30)
        screen.text("dead of night")
        screen.move(50,40)
        screen.text("it's impressive")
        screen.move(0,50)
        screen.text("rich and powerful repertoire")
         screen.move(0,60)
        screen.text("is worthy of anyones envy.")
      elseif info == false then
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/gale1.png", 38, 20)
        screen.move(65, 10)
        screen.text_center("nightingale")
      end]]
    elseif active_bird_name == "blackbird" then
      if info == true then
        display_note = false
        display_exl = false
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/blackbird_info.png", 0, 0)
        screen.move(50,9)
        screen.font_size(11)
        screen.font_face(15)
        screen.text("euroasian")
        screen.move(50,21)
        screen.text("blackbird")
        screen.move(50,30)
        screen.font_size(8)
        screen.font_face(1)
        screen.text("soundtrack to")
        screen.move(50,40)
        screen.text("summer, this bird")
        screen.move(0,50)
        screen.text("can improvise with a large")
        screen.move(0,60)
        screen.text("catalogue of complex beauty.")
      elseif info == false then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/blackbird1.png", 38, 18)
      screen.move(65, 10)
      screen.text_center("euroasian blackbird")
    end
    elseif active_bird_name == "wren" then
      if info == true then
        --TODO: put bird info in separate functions in the lib/birds table (keep redraw tidy).
        display_note = false
        display_exl = false
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/wren_info.png", 0, 0)
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
      else
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/wren1.png", 38, 20)
        screen.move(65, 10)
        screen.text_center("euroasian wren")
      end
    end
  end
  screen.update()
end
-------- UTILITIES --------
function r()
  norns.script.load(norns.state.script)
end

function screen_redraw()
  if dirtyscreen then
    redraw()
    dirtyscreen = false
  end
end

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
