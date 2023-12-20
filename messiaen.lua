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

---------------------------------------------------------------------------
-- TODO: fix garden mode
-- TODO: flip bird image with direction
-- TODO: position main screen parameters according to ENC2 / ENC3
-- TOOD: position birds in garden mode and store the params in temp file.
-- TODO: check buffer positions (copy mono working?)
-- TODO: add feed birds option for garden
---------------------------------------------------------------------------
_f = require 'filters'
bird = include 'lib/birds'

-------- VARIABLES --------

-- constants
REC_LOOP_SIZE = 60
MAX_SEED_LENGTH = 2
FADE_TIME = 0.01 
MAX_BUFFER = 350

-- bird variables
NUM_BIRDS = 4
bird_is_singing = false
main_bird_voice = 1
separation = 2.2
direction = 0 

bird_voice = {}
for i = 1, NUM_BIRDS do
  bird_voice[i] = {}
  bird_voice[i].name = ""
  bird_voice[i].level = 0
  bird_voice[i].pan = 0
  bird_voice[i].cutoff = 18500
  bird_voice[i].filter_q = 2
  bird_voice[i].pos = (REC_LOOP_SIZE + 1) -- + (i - 1) -- position for playback on buffer 1 TODO: decide whether the birds have individual buffers or not. me think yes.
  bird_voice[i].loop_size = 0.5
end

-- seed variables (rec voice)
seed_voice = 5 -- sofcut voice 5 
seed_voice_pos = 1
threshold_upper = 0
threshold_lower = 0

-- forest variables
forest_voice = 6
forest_level = 0.3
forest_is_planted = true
garden_is_planted = false
default_forest = "/home/we/dust/code/messiaen/assets/forests/robinwren.wav" 

-- UI variables
k1_pressed = false
k2_pressed = false
info = false
is_memorizing = false

-- bird clocks
current_bird_clock = nil
garden_bird_clock = {}
for i = 1, NUM_BIRDS do
  garden_bird_clock[i] = nil
end

-- bird table: needs to correspond with bird.names from lib/birds
bird_tab = {bird.wren, bird.robin, bird.blackbird, bird.chaffinch, bird.g_tit, bird.green_finch, bird.willow_warbler}

-------- FUNCTIONS --------

-- the ultimate ultra super bird clocking function, hell yeah.
function play_birdsongs(bird, voice)
  local voice = voice or 1
  while true do
    local song = math.random(1, #bird)
    -- play notes
    softcut.level(voice, bird_voice[voice].level)
    for i = 1, #bird[song] do
      local current_note = bird[song][i]
      local rate = ntor(current_note.r) * 3 * direction
      local slew = current_note.pb
      local level = current_note.l
      softcut.rate(voice, rate)
      softcut.rate_slew_time(voice, slew)
      softcut.level(voice, level)
      clock.sleep(current_note.d)
    end
    softcut.level(voice, 0)
    clock.sleep(math.random(1) + separation)
  end
end

-- load forest file
function load_audio(path)
  if path ~= "cancel" and path ~= "" then
    local ch, len = audio.file_info(path)
    if ch > 0 and len > 0 then
      softcut.buffer_clear_channel(2)
      softcut.buffer_read_mono(path, 0, 1, -1, 1, 2, 0, 1)
      local l = math.min(len / 48000, MAX_BUFFER)
      softcut.loop_start(forest_voice, 1)
      softcut.loop_end(forest_voice, 1 + l)
      params:set("plant_forest", 2)
      params:set("load_forest", "")
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

function grab_seed()
  softcut.query_position(seed_voice)
  is_memorizing = true
  dirtyscreen = true
  clock.run(function()
    clock.sleep(MAX_SEED_LENGTH)
    softcut.buffer_copy_mono(1, 1, seed_voice_pos, bird_voice[1].pos, MAX_SEED_LENGTH, FADE_TIME) -- need to copy to the other bird buffers too
    is_memorizing = false
    dirtyscreen = true
  end)
end

function get_pos(i, pos) -- get and store softcut position (callback)
  seed_voice_pos = pos - FADE_TIME
  print(i, pos)
end

function set_bird_level()
  if bird_is_singing then
    softcut.level(main_bird_voice, bird_voice[main_bird_voice].level)
  else
    softcut.level(main_bird_voice, 0)
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
  softcut.rate(main_bird_voice, 1)
end

-- garden
function toggle_garden()  
  if garden_is_planted then
    --save_bird_params()
    call_garden_birds()
  else
    --restore_bird_params()
    stop_garden_birds()
  end
end

function call_garden_birds()
  -- cancel active bird if singing
  if current_bird_clock ~= nil then
    clock.cancel(current_bird_clock)
    bird_is_singing = false
  end
  -- call main bird
  call_bird(bird_tab[params:get("main_bird_active")])
  -- call visitors
  call_visitor_clock = clock.run(function()
    for i = 1, 3 do
      clock.sleep(math.random(2, 8))
      local visitor = params:get("visitor_"..i)
      garden_bird_clock[i] = clock.run(play_birdsongs, bird_tab[visitor], i + 1)
    end
  end)
end

function stop_garden_birds()
  if current_bird_clock ~= nil then
    clock.cancel(current_bird_clock)
    bird_is_singing = false
  end
  if call_visitor_clock ~= nil then
    clock.cancel(call_visitor_clock)
  end
  for i = 1, 3 do
    if garden_bird_clock[i] ~= nil then
      clock.cancel(garden_bird_clock[i])
    end
    softcut.level(i, 0)
  end
end

function randomize_garden_bird_params()
  -- TODO
end

---------- init function -----------
function init()
  
  -- sofcut setup
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  audio.level_tape_cut(0)
  softcut.buffer_clear()

  for i = 1, NUM_BIRDS do -- softcut voices 1 - 4
    softcut.enable(i, 1)
    softcut.buffer(i, 1)
    softcut.level(i, 0)
    softcut.pan(i, 0)
    softcut.rate(i, 1.0)
    softcut.loop(i, 1)
    softcut.loop_start(i, bird_voice[i].pos)
    softcut.loop_end(i, bird_voice[i].pos + bird_voice[i].loop_size)
    softcut.position(i, bird_voice[i].pos)
    softcut.play(i, 1)
    softcut.fade_time(i, FADE_TIME)
    -- slew
    softcut.level_slew_time(i, 0.2)
    softcut.pan_slew_time(i, 0.1)
    softcut.rate_slew_time(i, 0)    
    -- filter
    softcut.post_filter_dry(i, 0)
    softcut.post_filter_lp(i, 1)
    softcut.post_filter_fc(i, bird_voice[i].cutoff)
    softcut.post_filter_rq(i, bird_voice[i].filter_q)
  end

  -- softcut recording -- softcut voice 5
  softcut.enable(seed_voice, 1)
  softcut.buffer(seed_voice, 1)
  -- route adc to seed_voice
  softcut.level_input_cut(1, seed_voice, 1.0)
  softcut.level_input_cut(2, seed_voice, 1.0)
  -- enable rec and play
  softcut.rec(seed_voice, 1)
  softcut.play(seed_voice, 1)
  -- set levels
  softcut.level(seed_voice, 0)
  softcut.pan(seed_voice, 0)
  softcut.rec_level(seed_voice, 1)
  softcut.pre_level(seed_voice, 0)
  -- set loop
  softcut.rate(seed_voice, 1)
  softcut.loop(seed_voice, 1)
  softcut.loop_start(seed_voice, 1)
  softcut.loop_end(seed_voice, 5)
  softcut.position(seed_voice, 1)
  softcut.fade_time(seed_voice, FADE_TIME)
  -- forest playback -- softcut voice 6
  softcut.enable(forest_voice, 1) 
  softcut.buffer(forest_voice, 2)
  softcut.level(forest_voice, 0.5)
  softcut.rate(forest_voice, 1)
  softcut.loop(forest_voice, 1)
  softcut.loop_start(forest_voice, 0)
  softcut.loop_end(forest_voice, MAX_BUFFER)
  softcut.position(forest_voice, 1)
  softcut.play(forest_voice, 1)
  softcut.fade_time(forest_voice, 2)

  -- callbacks
  softcut.event_position(get_pos)
    
  -- bird voice parameters
  params:add_separator("bird_voicing", "birds")

  local bird_params = {"main_bird", "visitor_1", "visitor_2", "visitor_3"}
  local bird_param_names = {"main bird", "visitor 1", "visitor 2", "visitor 3"}

  for i = 1, 4 do
    params:add_group(bird_params[i], bird_param_names[i], 5)

    params:add_option(bird_params[i].."_active", "bird", bird.names, 1)
    params:set_action(bird_params[i].."_active", function (idx) bird_voice[i].name = bird.names[idx] change_bird(bird_tab[idx]) dirtyscreen = true end)

    params:add_control(bird_params[i].."_level", "level", controlspec.new(0, 1, 'lin', 0, 0.5), function(param) return (round_form(util.linlin(0, 1, 0, 100, param:get()), 1, "%")) end)
    params:set_action(bird_params[i].."_level", function(val) bird_voice[i].level = val set_bird_level() dirtyscreen = true end)

    params:add_control(bird_params[i].."_mood", "feistiness", controlspec.new(0.01, 1, 'lin', 0, 0.1), function(param) return (round_form(util.linlin(0.01, 1, 0, 100, param:get()), 1, "%")) end)
    params:set_action(bird_params[i].."_mood", function(val) bird_voice[i].loop_size = val softcut.loop_end(i, bird_voice[i].pos + bird_voice[i].loop_size) end)

    params:add_control(bird_params[i].."_pan", "position", controlspec.new(-1, 1, 'lin', 0, 0, ""))
    params:set_action(bird_params[i].."_pan", function(val) bird_voice[i].pan = val softcut.pan(i, val) end)

    params:add_control(bird_params[i].."_cutoff", "area", controlspec.new(20000, 240, 'exp', 0, 18500), function(param) return (round_form(util.explin(240, 20000, 100, 0, param:get()), 1, "%")) end)
    params:set_action(bird_params[i].."_cutoff", function(x) bird_voice[i].cutoff = x softcut.post_filter_fc(i, x) end)
  end

  -- rec parameters
  params:add_separator("bird_rec", "recording")
  params:add_control("rec_threshold", "threshold", controlspec.new(-20, 0, 'lin', 0, -12, "dB"))
  params:set_action("rec_threshold", function(val) threshold_upper = util.round((util.dbamp(val) / 10), 0.01) threshold_lower = threshold_upper * 0.6 end)

  -- garden parameters
  params:add_separator("garden", "garden")

  params:add_option("invite_birds", "invite friends", {"no", "yes"}, 1)
  params:set_action("invite_birds", function(val) garden_is_planted = val == 2 and true or false toggle_garden() end)

  params:add_option("position_birds", "position birds", {"no", "yes"}, 1)
  params:set_action("position_birds", function(val)  end)

  params:add_control("bird_talk", "song density", controlspec.new(0, 5, 'lin', 0, 0), function(param) return (round_form(util.linlin(0, 5, 100, 0, param:get()), 1, "%")) end)
  params:set_action("bird_talk", function(val) separation = val + 2.2 end)

  params:add_option("feed_birds", "feed birds", {"simultanious", "sequential", "random"}, 1)
  params:set_action("feed_birds", function(val) feed_mode = val end)

  -- forest parameters
  params:add_separator("forest_params", "forest")
  params:add_file("load_forest", "> select forest", "")
  params:set_action("load_forest", function(path) load_audio(path) end)

  params:add_option("plant_forest", "plant?", {"no", "yes"}, 2)
  params:set_action("plant_forest", function(val) forest_is_planted = val == 2 and true or false toggle_forest() end)

  params:add_control("forest_level", "intensity", controlspec.new(0, 1, 'lin', 0, 0.4), function(param) return (round_form(util.linlin(0, 1, 0, 100, param:get()), 1, "%")) end)
  params:set_action("forest_level", function(val) forest_level = val softcut.level(forest_voice, val) end)
  
  params:bang()

  params:set("load_forest", default_forest)

  -- metros
  screenredrawtimer = metro.init(function() screen_redraw() end, 1/15, -1)
  screenredrawtimer:start()

  -- setup smoothing for amp poll
  get_mean = _f.mean.new(10)

  -- threshold rec poll
  amp_in = {}
  amp_src = {"amp_in_l", "amp_in_r"}
  amp_prev_level = 0
  threshold_reached = false
  for ch = 1, 2 do
    amp_in[ch] = poll.set(amp_src[ch])
    amp_in[ch].time = 1/100
    amp_in[ch].callback = function(val)
      local amp_level = get_mean:next(util.round(val, 0.01))
      if amp_level > threshold_upper and not threshold_reached then
        threshold_reached = true 
        grab_seed()
        amp_prev_level = amp_level
        --print(amp_level.." is above thresh ".. threshold_upper)
      elseif amp_level < threshold_lower then
        if threshold_reached then
          --print(amp_level.." is below thresh ".. threshold_lower)
        end
        threshold_reached = false
      end
    end
    amp_in[ch]:start()
  end


-- end of init
end
  
-------- UI --------

-- ENCODERS
function enc(n, d)
  if garden_is_planted then
    if n == 1 then
      -- main volume -- mult with variable with range 0-1
    elseif n == 2 then
      -- spread (panning) mult with variable with range -1 to 1
    elseif n == 3 then
      params:delta("bird_talk", d)
    end
  else
    if n == 1 then
      params:delta("main_bird_active", d)
    end
    if shift then
      if n == 2 then
        params:delta("main_bird_mood", d) -- whatever makes more sense to you
      elseif n == 3 then
        params:delta("main_bird_pan", d) -- whatever makes more sense to you
      end
    else
      if n == 2 then
        params:delta("main_bird_cutoff", d)
      elseif n == 3 then
        params:delta("main_bird_level", d)
      end
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
        local bird = bird_tab[params:get("main_bird_active")]
        call_bird(bird)
      else
        stop_bird(main_bird_voice)
      end
    end
  elseif n == 3 and z == 1 then
    if k1_pressed then
      garden_is_planted = not garden_is_planted
      toggle_garden()
    else
      --TODO: flip bird image!
      direction = direction == 1 and -1 or 1
    end
  end
  dirtyscreen = true
end

function redraw()
  screen.clear()
  if garden_is_planted then
    screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/garden2.png", 0, 0)
  else
    local main_bird_name = bird_voice[main_bird_voice].name
    screen.move(10, 50)
    screen.font_size(8)
    screen.text("area: ")
    screen.move(118, 50)
    screen.text_right(params:string("main_bird_cutoff"))
    screen.move(10, 60)
    screen.text("chirp: ")
    screen.move(118, 60)
    screen.text_right(params:string("main_bird_level"))

    if bird_is_singing and not info then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/note.png", 90, 20)
    end
    
    if is_memorizing and not info then
      screen.level(15)
      screen.font_size(16)
      screen.move(108, 31)
      screen.text("!")
    end
    
    screen.font_size(8)
    
    if main_bird_name == "weird" then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/weird1.png", 38, 18)
      screen.move(65, 10)
      screen.text_center("weird boi")
    elseif main_bird_name == "awesomebird" then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/awesome1.png", 38, 18)
      screen.move(65, 10)
      screen.text_center("good boi")
    elseif main_bird_name =="green finch" then
      if info == true then
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
    elseif main_bird_name == "willow warbler" then
      if info == true then
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
--[[    elseif main_bird_name =="nuthach" then
      if info == true then
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
    elseif main_bird_name =="great tit" then
      if info == true then
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
    elseif main_bird_name =="chaffinch" then
      if info == true then
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
--[[    elseif main_bird_name == "trush" then
      if info == true then
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
    elseif main_bird_name == "robin" then
      if info == true then
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
--[[    elseif main_bird_name =="nightingale" then
      if info == true then
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
    elseif main_bird_name == "blackbird" then
      if info == true then
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
    elseif main_bird_name == "wren" then
      if info == true then
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

function round_form(param, quant, form)
  return(util.round(param, quant)..form)
end

function screen_redraw()
  if dirtyscreen then
    redraw()
    dirtyscreen = false
  end
end

function cleanup()
  print("cleaned up all the bird poop")
end
