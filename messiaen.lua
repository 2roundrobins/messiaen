--- messiaen v0.1.2 @fellowfinch
--- @sonocircuit GUI @mechtai.
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
--- E2 bird mood
--- E3 chirp volume
--- K1+E2 distance
--- K1+E3 position
---
--- K2 toggle birdsong
--- K3 toggle recording
--- K1+K2 toggle garden
--- K1+K3 toggle info
---
--- press K3 and play something
--- for the bird and the active
--- bird will listen )))
--- make it sing by pressing K2.
--- 

_flt = require 'filters'
bird = include 'lib/birds'

-------- VARIABLES --------

-- constants
REC_LOOP_SIZE = 60
MAX_SEED_LENGTH = 2
FADE_TIME = 0.01 
MAX_BUFFER = 350
NUM_BIRDS = 4

-- UI variables
info = false
k1_pressed = false
is_memorizing = false

-- bird variables
bird_params = {"main_bird", "visitor_1", "visitor_2", "visitor_3"}
bird_param_names = {"main bird", "visitor 1", "visitor 2", "visitor 3"}

main_bird = 1
separation = 2.2
bird_to_feed = 0
global_level = 1

bird_voice = {}
for i = 1, NUM_BIRDS do
  bird_voice[i] = {}
  bird_voice[i].name = ""
  bird_voice[i].key = ""
  -- levels
  bird_voice[i].level = 0
  bird_voice[i].pan = 0
  bird_voice[i].cutoff = 18500
  -- playback
  bird_voice[i].pos = (REC_LOOP_SIZE + 1) + (MAX_SEED_LENGTH + 1) * (i - 1)
  bird_voice[i].loop_size = 0.5
  -- activity
  bird_voice[i].active = false -- state of the bird. if true then its singing else it aint.
  bird_voice[i].clock = nil -- placeholder variable for the clock id.
  -- temp storage
  bird_voice[i].prev_pan = 0
  bird_voice[i].prev_cutoff = 18500
  bird_voice[i].prev_loop_size = 0.5
end

-- movement variables
auto_position = false
birds_moving = false

-- seed variables (rec voice)
seed_voice = 5
seed_voice_pos = 1
threshold_upper = 0
threshold_lower = 0
thresh_armed = false

-- forest variables (ambient voice)
forest_voice = 6
forest_level = 0.2
forest_is_planted = true
garden_is_planted = false
default_forest = "/home/we/dust/audio/hermit_leaves.wav" -- @andy: you need to trim the file as there is a gab (does not loop seamlessly).
--default_forest = "/home/we/dust/audio/messiaen/assets/forests/park_life.flac"


-------- FUNCTIONS --------

-- the ultimate ultra super bird clocking function.
function play_birdsongs(bird_num, bird_tab)
  local bird_num = bird_num or 1
  while true do
    local birdsong = bird_tab[math.random(1, #bird_tab)]
    -- play notes
    for i = 1, #birdsong do
      local current_note = birdsong[i]
      local rate = math.pow(2, current_note.r / 12) * 3
      local slew = current_note.pb
      local level = current_note.l * bird_voice[bird_num].level * global_level
      softcut.rate(bird_num, rate)
      softcut.rate_slew_time(bird_num, slew)
      softcut.level(bird_num, level)
      clock.sleep(current_note.d)
    end
    softcut.level(bird_num, 0)
    clock.sleep(math.random(1) + separation)
  end
end

function get_pos(i, pos)
  seed_voice_pos = pos - FADE_TIME
end

function grab_seed()
  softcut.query_position(seed_voice)
  is_memorizing = true
  dirtyscreen = true
  clock.run(function()
    clock.sleep(MAX_SEED_LENGTH)
    if (feed_mode == 1 or not garden_is_planted) then
      for i = 1, 4 do
        softcut.buffer_copy_mono(1, 1, seed_voice_pos, bird_voice[i].pos, MAX_SEED_LENGTH, FADE_TIME)
      end
    elseif feed_mode == 2 then
      bird_to_feed = util.wrap(bird_to_feed + 1, 1, 4)
      softcut.buffer_copy_mono(1, 1, seed_voice_pos, bird_voice[bird_to_feed].pos, MAX_SEED_LENGTH, FADE_TIME)
    elseif feed_mode == 3 then
      local bird_num = math.random(1, 4)
      softcut.buffer_copy_mono(1, 1, seed_voice_pos, bird_voice[bird_num].pos, MAX_SEED_LENGTH, FADE_TIME)
    end
    is_memorizing = false
    dirtyscreen = true
  end)
end

function set_softcut_input(option)
  -- set source
  audio.level_adc_cut(option < 4 and 1 or 0)
  --audio.level_eng_cut(option == 4 and 1 or 0)
  -- set softcut inputs
  if option == 1 or option > 3 then -- summed
    softcut.level_input_cut(1, seed_voice, 0.707)
    softcut.level_input_cut(2, seed_voice, 0.707)
  elseif option == 2 then -- L IN
    softcut.level_input_cut(1, seed_voice, 1)
    softcut.level_input_cut(2, seed_voice, 0)
 elseif option == 3 then -- R IN
    softcut.level_input_cut(1, seed_voice, 0)
    softcut.level_input_cut(2, seed_voice, 1)
  end
end

function save_bird_params()
  for i = 1, 4 do
    bird_voice[i].prev_loop_size = bird_voice[i].loop_size
    bird_voice[i].prev_pan = bird_voice[i].pan
    bird_voice[i].prev_cutoff = bird_voice[i].cutoff
  end
end

function restore_bird_params()
  for i = 1, 4 do
    params:set(bird_params[i].."_mood", bird_voice[i].prev_loop_size)
    params:set(bird_params[i].."_pan", bird_voice[i].prev_pan)
    params:set(bird_params[i].."_cutoff", bird_voice[i].prev_cutoff)
  end
end

function rnd_bird_params()
  for i = 1, 4 do
    params:set(bird_params[i].."_mood", math.random())
    params:set(bird_params[i].."_pan", math.random(-10, 10) / 10)
    params:set(bird_params[i].."_cutoff", math.random())
  end
end

---- ///// new world order ////// ----

-- @andy I re-wrote the way the whole bird-clock management works.
-- now there are four clocks for each bird. that's it.
-- all the functions take bird_num (1-4) + the bird table as arguments.

function call_bird(bird_num, bird_tab) -- @andy: cancel bird clock if running, call the bird according to the fed arguments and set activity to true
  if bird_voice[bird_num].clock ~= nil then
    clock.cancel(bird_voice[bird_num].clock)
  end
  bird_voice[bird_num].clock = clock.run(play_birdsongs, bird_num, bird_tab)
  bird_voice[bird_num].active = true
end

function silent_bird(bird_num) -- @andy: cancel bird clock if running, reset softcut levels and set bird activity to false
  if bird_voice[bird_num].clock ~= nil then
    clock.cancel(bird_voice[bird_num].clock)
  end
  softcut.level(bird_num, 0)
  softcut.rate(bird_num, 1)
  bird_voice[bird_num].active = false
end

function change_bird(bird_num, idx) -- @andy: chage bird is only called via params. bird_num and index als arguments
  bird_voice[bird_num].name = bird.names[idx] -- assign the bird name (string) (actually only required for the main bird but let's keep this).
  bird_voice[bird_num].key = bird.keys[idx] -- assign the bird key (string) which is required to call the birds. needed to add this as the bird names do not always coincide with the table entries.
  if bird_voice[bird_num].active then 
    call_bird(bird_num, bird[bird_voice[bird_num].key])
  end
  dirtyscreen = true
end

function toggle_garden()  
  if garden_is_planted then
    save_bird_params()
    -- call birds
    call_bird(main_bird, bird[bird_voice[main_bird].key]) 
    call_visitors_clock = clock.run(function()
      for bird_num = 2, 4 do
        clock.sleep(math.random(2, 8))
        call_bird(bird_num, bird[bird_voice[bird_num].key])
      end
    end)
    if auto_position then rnd_bird_params() end
  else
    -- silent birds
    if call_visitors_clock ~= nil then  -- @andy: if garden mode is toggled off while the visitor are still being initialized we want to cancel the clock
      clock.cancel(call_visitors_clock)
    end
    for bird_num = 1, 4 do
      silent_bird(bird_num) -- @andy: all birds are silenced
    end
    if auto_position then restore_bird_params() end
  end
end
---- ///// ends here ////// ----

-- set the birds free
-- @andy: trig_bird_movment() is a clock coro that triggers move_birds() during garden mode if auto_position is true.
--        the higher bird_movement_prob is the more often move_birds() gets called.
function trig_bird_movement()
  while true do
    clock.sleep(1)
    if auto_position and garden_is_planted then
      if math.random(0, 100) < bird_movement_prob then
        move_birds()
      end
    end
  end
end

-- @andy: move_birds sets the pan position and cutoff of the birds sequentially to simulate a somewhat "natural" behaviour. -- @Sacha: FUCKING GENIUS!
--        we don't want all birds to move at the same time and abruptly,
--        hence introducing pan_slew. unfortunatley there is no slew for cutoff freq.
--        birds 2, 3 and 4 have boundries and are based on the values of bird 1 so that they can't all clump in one place. 
function move_birds()
  if birds_moving == false then
    birds_moving = true
    clock.run(function()
      local num = 0
      local new_position
      local new_distance
      -- @andy clock cycles 4 times. as birds_moving is set to false when num == 4. --> clock cancels itself.
      while birds_moving do
        num = num + 1
        -- set values
        if num == 1 then
          new_position = math.random(-10, 10) / 10
          new_distance = math.random()
        elseif num == 2 then
          local pos_min = bird_voice[num - 1].pan < 0 and 0 or -10
          local pos_max = bird_voice[num - 1].pan > 0 and 0 or 10
          new_position = math.random(pos_min, pos_max) / 10
          new_distance = math.random()
        else
          local pos_min = bird_voice[num - 1].pan < 0 and 0 or -10
          local pos_max = bird_voice[num - 1].pan > 0 and 0 or 10
          local dis_min = bird_voice[num - 1].cutoff < 0.5 and 0 or 5
          local dis_max = bird_voice[num - 1].cutoff > 0.5 and 10 or 5
          new_position = math.random(pos_min, pos_max) / 10
          new_distance = math.random(dis_min, dis_max) / 10
        end
        -- set params
        softcut.pan_slew_time(num, math.random(0, 20) / 10)
        params:set(bird_params[num].."_pan", new_position)
        params:set(bird_params[num].."_cutoff", new_distance)
        clock.sleep(math.random(2, 10) / 10) -- sleep between 0.2s and 1s
        -- reset pan slew
        softcut.pan_slew_time(num, 0)
        -- check progress and flip bool
        if num == 4 then birds_moving = false end
      end
    end)
  end
end

function load_audio(path)
  if path ~= "cancel" and path ~= "" then
    local ch, len = audio.file_info(path)
    if ch > 0 and len > 0 then
      softcut.buffer_clear_channel(2)
      softcut.buffer_read_mono(path, 0, 1, -1, 1, 2, 0, 1)
      local l = math.min(len / 48000, MAX_BUFFER)
      softcut.loop_start(forest_voice, 1)
      softcut.loop_end(forest_voice, 1 + l)
      print("file loaded: "..path.." is "..l.."s")
    else
      print("not a sound file")
      params:set("plant_forest", 1)
      params:set("load_forest", "")
    end
  end
end

function set_forest_level()
  if forest_is_planted then
    softcut.level(forest_voice, forest_level)
  else
    softcut.level(forest_voice, 0)
  end
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
    softcut.post_filter_rq(i, 2)
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
  softcut.level(forest_voice, 0)
  softcut.rate(forest_voice, 1)
  softcut.loop(forest_voice, 1)
  softcut.loop_start(forest_voice, 0)
  softcut.loop_end(forest_voice, MAX_BUFFER)
  softcut.position(forest_voice, 1)
  softcut.play(forest_voice, 1)
  softcut.fade_time(forest_voice, 0.01)

  -- callbacks
  softcut.event_position(get_pos)
    
  -- bird voice parameters
  params:add_separator("bird_voicing", "birds")

  params:add_control("global_level", "main level", controlspec.new(0, 1, 'lin', 0, 1), function(param) return (round_form(util.linlin(0, 1, 0, 100, param:get()), 1, "%")) end)
  params:set_action("global_level", function(val) global_level = val end)

  for i = 1, 4 do
    params:add_group(bird_params[i], bird_param_names[i], 5)

    params:add_option(bird_params[i].."_active", "bird", bird.names, i)
    params:set_action(bird_params[i].."_active", function (idx) change_bird(i, idx) end)

    params:add_control(bird_params[i].."_level", "level", controlspec.new(0, 1, 'lin', 0, 0.4), function(param) return (round_form(util.linlin(0, 1, 0, 100, param:get()), 1, "%")) end)
    params:set_action(bird_params[i].."_level", function(val) bird_voice[i].level = val dirtyscreen = true end)

    params:add_control(bird_params[i].."_mood", "mood", controlspec.new(0.01, 1, 'lin', 0, 0.38), function(param) return (round_form(util.linlin(0.01, 1, 0, 100, param:get()), 1, "%")) end)
    params:set_action(bird_params[i].."_mood", function(val) bird_voice[i].loop_size = val softcut.loop_end(i, bird_voice[i].pos + bird_voice[i].loop_size) end)

    params:add_control(bird_params[i].."_pan", "position", controlspec.new(-1, 1, 'lin', 0, 0, ""), function(param) return pan_display(param:get()) end)
    params:set_action(bird_params[i].."_pan", function(val) bird_voice[i].pan = val softcut.pan(i, val) end)

    params:add_control(bird_params[i].."_cutoff", "distance", controlspec.new(0, 1, 'lin', 0, 0.4), function(param) return (round_form(util.linlin(0, 1, 0, 100, param:get()), 1, "%")) end)
    params:set_action(bird_params[i].."_cutoff", function(x) local freq = util.linexp(0, 1, 20000, 400, x) bird_voice[i].cutoff = freq softcut.post_filter_fc(i, freq) end)
  end

  -- rec parameters
  params:add_separator("bird_rec", "recording")

  params:add_option("input_source", "input source", {"sum l+r", "mono l", "mono r"}, 1) -- @andy: added a parameter to select the input source.
  params:set_action("input_source", function(option) set_softcut_input(option) end)            -- if nbin mod is installed you can use a nb voice as source (eng).

  params:add_control("rec_threshold", "threshold", controlspec.new(-20, 0, 'lin', 0, -18, "dB"))
  params:set_action("rec_threshold", function(val)
    threshold_upper = util.round((util.dbamp(val) / 10), 0.01)
    threshold_lower = threshold_upper * 0.6 -- se magic number
  end)

  -- garden parameters
  params:add_separator("garden", "garden")

  params:add_option("invite_birds", "invite friends", {"no", "yes"}, 1)
  params:set_action("invite_birds", function(val) garden_is_planted = val == 2 and true or false toggle_garden() end)

  params:add_option("position_birds", "birds position", {"manual", "auto"}, 1)
  params:set_action("position_birds", function(mode) auto_position = mode == 2 and true or false build_menu() end)

  params:add_control("bird_activity", "bird activity", controlspec.new(0, 1, 'lin', 0, 0), function(param) return (round_form(param:get() * 100, 1, "%")) end)
  params:set_action("bird_activity", function(val) bird_movement_prob = val * 100 end) 

  -- juggle the numbers for lager separation. i.e. increase 7.2 and increase the max val in the controlspec
  params:add_control("bird_talk", "song density", controlspec.new(0, 5, 'lin', 0, 2), function(param) return (round_form(util.linlin(0, 5, 0, 100, param:get()), 1, "%")) end)
  params:set_action("bird_talk", function(val) separation = 7.2 - val end) 

  params:add_option("feed_birds", "feed birds", {"simultanious", "sequential", "random"}, 1)
  params:set_action("feed_birds", function(val) feed_mode = val end)

  -- forest parameters
  params:add_separator("forest_params", "forest")
  params:add_file("load_forest", "> select forest", "")
  params:set_action("load_forest", function(path) load_audio(path) end)

  params:add_option("plant_forest", "plant?", {"no", "yes"}, 2)
  params:set_action("plant_forest", function(val) forest_is_planted = val == 2 and true or false softcut.position(forest_voice, 1) set_forest_level() end)

  params:add_control("forest_level", "intensity", controlspec.new(0, 1, 'lin', 0, 0.3), function(param) return (round_form(util.linlin(0, 1, 0, 100, param:get()), 1, "%")) end)
  params:set_action("forest_level", function(val) forest_level = val set_forest_level() end)

  params:bang()
  params:set("load_forest", default_forest)
  
  -- metros
  screenredrawtimer = metro.init(function() screen_redraw() end, 1/15, -1)
  screenredrawtimer:start()

  -- clocks
  clock.run(trig_bird_movement)

  -- setup smoothing for amp poll
  get_mean = _flt.mean.new(10)

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
      if amp_level > threshold_upper and not threshold_reached and thresh_armed then
        threshold_reached = true 
        grab_seed()
        amp_prev_level = amp_level
      elseif amp_level < threshold_lower then
        threshold_reached = false
      end
    end
    amp_in[ch]:start()
  end
-- end of init
end
  
-------- UI --------

function enc(n, d)
  if garden_is_planted then
    if n == 1 then
      params:delta("global_level", d)
    elseif n == 2 then
      params:delta("main_bird_pan", d)
      params:delta("visitor_1_pan", -d)
      params:delta("visitor_2_pan", d * 0.5)
      params:delta("visitor_3_pan", -d * 0.5)
    elseif n == 3 then
      params:delta("bird_talk", d)
    end
  else
    if n == 1 then
      params:delta("main_bird_active", d)
    end
    if k1_pressed then
      if n == 2 then
        params:delta("main_bird_cutoff", d)
      elseif n == 3 then
        params:delta("main_bird_pan", d)
      end
    else
      if n == 2 then
        params:delta("main_bird_mood", d)
      elseif n == 3 then
        params:delta("main_bird_level", d)
      end
    end
  end
  dirtyscreen = true
end

function key(n, z)
  if n == 1 then
    k1_pressed = z == 1 and true or false
  end
  if n == 2 and z == 1 then
    if k1_pressed then -- @andy: moved garden_mode to K2 as its more intuitive to use the same key to call birds. -- totally agree
      params:set("invite_birds", garden_is_planted and 1 or 2)
    else
      if garden_is_planted then
        move_birds() -- @andy: while in garden mode we can manually trigger position changes even if autoposition is off. --am i doing something wrong here, k2 should give me some auditory feedback nop?
      else
        if bird_voice[main_bird].active then -- @andy: while not in garden_mode use K2 to toggle the main bird.
          silent_bird(main_bird)             --        bird_is_singing has been replaced by bird_voice[main_bird].active
        else
          call_bird(main_bird, bird[bird_voice[main_bird].key])
        end
      end
    end
  elseif n == 3 and z == 1 then
    if k1_pressed then
      info = not info 
    else
      thresh_armed = not thresh_armed
    end
  end
  dirtyscreen = true
end

function redraw()
  screen.clear()
  screen.level(15)
  if garden_is_planted then
    screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/garden.png", 0, 0)
    if thresh_armed then
      screen.level(is_memorizing and 15 or 1)
      screen.font_size(16)
      screen.move(62, 18)
      screen.text_center(">)(<") -- @andy: using this to visualize whether we are in recording mode or not.
    end                          --        you might want to replace it with a png? -- actually works fine and we dont need new kbs :D
  else
    local name_e2 = k1_pressed and "distance" or "mood"
    local value_e2 = k1_pressed and params:string("main_bird_cutoff") or params:string("main_bird_mood")
    local name_e3 = k1_pressed and "position" or "chirp"
    local value_e3 = k1_pressed and params:string("main_bird_pan") or params:string("main_bird_level")
    screen.font_size(8)
    screen.move(2, 50)
    screen.text(name_e2)
    screen.move(126, 50)
    screen.text_right(name_e3)
    screen.level(4)
    screen.move(2, 60)
    screen.text(value_e2)
    screen.move(126, 60)
    screen.text_right(value_e3)

    if bird_voice[main_bird].active and not info then
      screen.level(15)
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/note.png", 98, 20)
    end
     
    if thresh_armed and not info then
      screen.level(is_memorizing and 15 or 1)
      screen.font_size(22)
      screen.move(108, 30)
      screen.text("(")
      screen.font_size(14)
      screen.move(116, 28)
      screen.text("(")
      screen.font_size(10)
      screen.move(121, 27)
      screen.text("(")
    end
    
    screen.level(15)
    screen.font_size(8)
    
    if bird_voice[main_bird].name == "weird" then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/weird1.png", 38, 18)
      screen.move(65, 10)
      screen.text_center("weird boi")
    elseif bird_voice[main_bird].name == "awesomebird" then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/awesome1.png", 38, 18)
      screen.move(65, 10)
      screen.text_center("good boi")
    elseif bird_voice[main_bird].name =="green finch" then
      if info == true then
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/greenfinch_info.png", 0, 0)
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
      elseif info == false and bird_voice[main_bird].active == true then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/greenfinch_sin.png", -2, 6)
      screen.move(65, 10)
      screen.text_center("greenfinch")
      elseif info == false then  
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/greenfinch1.png",-2, 6)
        screen.move(65, 10)
        screen.text_center("greenfinch")
      end
    elseif bird_voice[main_bird].name == "willow warbler" then
      if info == true then
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/willowwarbler_info.png", 0, 0)
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
      elseif info == false and bird_voice[main_bird].active == true then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/willowwarbler_sin.png", 0, 8)
      screen.move(65, 10)
      screen.text_center("willow warbler")
      elseif info == false then
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/willowwarbler1.png", 0, 8)
        screen.move(65, 10)
        screen.text_center("willow warbler")
      end
    elseif bird_voice[main_bird].name =="great tit" then
      if info == true then
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/greattit_info.png", 0, 0)
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
      elseif info == false and bird_voice[main_bird].active == true then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/greattit_sin.png", -8, 6)
      screen.move(65, 10)
      screen.text_center("great tit")
      elseif info == false then  
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/greattit1.png", -8, 6)
        screen.move(65, 10)
        screen.text_center("great tit")
      end
    elseif bird_voice[main_bird].name =="chaffinch" then
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
      elseif info == false and bird_voice[main_bird].active == true then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/chaffinch_sin.png",0, 8)
      screen.move(65, 10)
      screen.text_center("chaffinch")
      elseif info == false then
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/chaffinch1.png", 0, 8)
        screen.move(65, 10)
        screen.text_center("chaffinch")
      end
    elseif bird_voice[main_bird].name == "robin" then
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
        screen.text("in the calmness of winter.")
      elseif info == false and bird_voice[main_bird].active == true then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/robin_sin.png", 0, 8)
      screen.move(65, 10)
      screen.text_center("european robin")
      elseif info == false then
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/robin1.png", 0, 8)
        screen.move(65, 10)
        screen.text_center("european robin")
      end
    elseif bird_voice[main_bird].name == "blackbird" then
      if info == true then
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/blackbird_info.png", 0, 0)
        screen.move(50,9)
        screen.font_size(11)
        screen.font_face(15)
        screen.text("eurasian")
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
      elseif info == false and bird_voice[main_bird].active == true then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/blackbird_sin.png", 8, 8)
      screen.move(65, 10)
      screen.text_center("eurasian blackbird")
      elseif info == false then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/blackbird1.png", 8, 8)
      screen.move(65, 10)
      screen.text_center("eurasian blackbird")
    end
    elseif bird_voice[main_bird].name == "wren" then
      if info == true then
        screen.clear()
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/wren_info.png", 0, 0)
        screen.move(50,10)
        screen.font_size(11)
        screen.font_face(15)
        screen.text("eurasian")
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
      elseif info == false and bird_voice[main_bird].active == true then
      screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/wren_sin.png", 0, 8)
      screen.move(65, 10)
      screen.text_center("eurasian wren")
      else
        screen.display_png(_path.code .. "/messiaen/assets/brd_pngs/wren1.png", 0,8)
        screen.move(65, 10)
        screen.text_center("eurasian wren")
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

function pan_display(param)
  local pos_right = ""
  local pos_left = ""
  if param < -0.01 then
    pos_right = ""
    pos_left = "L< "
  elseif param > 0.01 then
    pos_right = " >R"
    pos_left = ""
  else
    pos_right = "<"
    pos_left = ">"
  end
  return (pos_left..math.abs(util.round(util.linlin(-1, 1, -100, 100, param), 1))..pos_right)
end

function build_menu()
  if auto_position then
    params:show("bird_activity")
  else
    params:hide("bird_activity")
  end
  _menu.rebuild_params()
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
