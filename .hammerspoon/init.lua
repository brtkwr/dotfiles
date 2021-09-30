hs.window.animationDuration = 0
units = {
  right30       = { x = 0.70, y = 0.00, w = 0.30, h = 1.00 },
  right50       = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
  right70       = { x = 0.30, y = 0.00, w = 0.70, h = 1.00 },
  left70        = { x = 0.00, y = 0.00, w = 0.70, h = 1.00 },
  left50        = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
  left30        = { x = 0.00, y = 0.00, w = 0.30, h = 1.00 },
  top30         = { x = 0.00, y = 0.00, w = 1.00, h = 0.30 },
  top50         = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
  top70         = { x = 0.00, y = 0.00, w = 1.00, h = 0.70 },
  bot30         = { x = 0.00, y = 0.70, w = 1.00, h = 0.30 },
  bot50         = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
  bot70         = { x = 0.00, y = 0.30, w = 1.00, h = 0.70 },
  upright30     = { x = 0.70, y = 0.00, w = 0.30, h = 0.50 },
  botright30    = { x = 0.70, y = 0.50, w = 0.30, h = 0.50 },
  upleft70      = { x = 0.00, y = 0.00, w = 0.70, h = 0.50 },
  botleft70     = { x = 0.00, y = 0.50, w = 0.70, h = 0.50 },
  maximum       = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 }
}

mash = { 'ctrl', 'alt', 'cmd' }
hs.hotkey.bind(mash, 'up',    function() hs.window.focusedWindow():move(units.top50,   nil, true) end)
hs.hotkey.bind(mash, 'down',  function() hs.window.focusedWindow():move(units.bot50,   nil, true) end)
hs.hotkey.bind(mash, 'left',  function() hs.window.focusedWindow():move(units.left50,  nil, true) end)
hs.hotkey.bind(mash, 'right', function() hs.window.focusedWindow():move(units.right50, nil, true) end)
hs.hotkey.bind(mash, 'm',     function() hs.window.focusedWindow():move(units.maximum, nil, true) end)
mish = { 'shift', 'alt', 'cmd' }
hs.hotkey.bind(mish, 'up',    function() hs.window.focusedWindow():move(units.top30,   nil, true) end)
hs.hotkey.bind(mish, 'down',  function() hs.window.focusedWindow():move(units.bot70,   nil, true) end)
hs.hotkey.bind(mish, 'left',  function() hs.window.focusedWindow():move(units.left30,  nil, true) end)
hs.hotkey.bind(mish, 'right', function() hs.window.focusedWindow():move(units.right70, nil, true) end)
hs.hotkey.bind(mish, 'm',     function() hs.window.focusedWindow():move(units.maximum, nil, true) end)
mush = { 'shift', 'ctrl', 'cmd' }
hs.hotkey.bind(mush, 'up',    function() hs.window.focusedWindow():move(units.top70,   nil, true) end)
hs.hotkey.bind(mush, 'down',  function() hs.window.focusedWindow():move(units.bot30,   nil, true) end)
hs.hotkey.bind(mush, 'left',  function() hs.window.focusedWindow():move(units.left70,  nil, true) end)
hs.hotkey.bind(mush, 'right', function() hs.window.focusedWindow():move(units.right30, nil, true) end)
hs.hotkey.bind(mush, 'm',     function() hs.window.focusedWindow():move(units.maximum, nil, true) end)
