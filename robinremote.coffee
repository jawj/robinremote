
tag = (opts) ->
  t = document.createElement opts.name ? 'div'
  for own k, v of opts
    switch k
      when 'name' then continue
      when 'parent' then v.appendChild t
      when 'prevSibling' then v.parentNode.insertBefore t, v.nextSibling
      when 'text' then t.appendChild document.createTextNode(v)
      else t[k] = v
  t

load = (opts, callback) ->
  url = opts.url
  opts.method ?= 'GET'
  if opts.search?
    kvps = ("#{escape(k)}=#{escape(v)}" for own k, v of opts.search)
    url += '?' + kvps.join('&')
  xhr = new XMLHttpRequest()
  xhr.onreadystatechange = ->
    if xhr.readyState is 4
      obj = if opts.type is 'json' then JSON.parse(xhr.responseText)
      else if opts.type is 'xml' then xhr.responseXML
      else xhr.responseText
      callback?(obj)
  xhr.open(opts.method, url, yes)
  xhr.send(opts.data)

cmd = (command) -> load(url: 'http://gravity.shrtct.com/' + command)

touchEvents = ['mousedown', 'touchstart']
releaseEvents = ['mouseup', 'touchend']

obeyMouseEvents = yes

rocker = (parent, downFunc, upFunc) ->
  outer = tag {className: 'rocker', parent}
  tag {className: 'shadow-hider', parent: outer}
  tag {className: 'divider', parent: outer}
  
  down = tag {parent: outer}
  tag {className: 'minus', parent: down}
    
  up = tag {parent: outer}
  tag {className: 'plus-h', parent: up}
  tag {className: 'plus-v', parent: up}
    
  downTouchLstn = (e) ->
    obeyMouseEvents = no if e.type is 'touchstart'
    return unless e.type is 'touchstart' or obeyMouseEvents
    down.className += ' highlighted'
    downFunc()
  down.addEventListener(e, downTouchLstn) for e in touchEvents
  
  upTouchLstn = (e) ->
    obeyMouseEvents = no if e.type is 'touchstart'
    return unless e.type is 'touchstart' or obeyMouseEvents
    up.className += ' highlighted'
    upFunc()
  up.addEventListener(e, upTouchLstn) for e in touchEvents
  
  releaseLstn = (e) -> up.className = 'up'; down.className = 'down'
  document.addEventListener(e, releaseLstn) for e in releaseEvents
  releaseLstn()

button = (parent, func) ->
  btn = tag {parent}
  
  touchLstn = (e) ->
    obeyMouseEvents = no if e.type is 'touchstart'
    return unless e.type is 'touchstart' or obeyMouseEvents
    btn.className += ' highlighted'
    func()  
  btn.addEventListener(e, touchLstn) for e in touchEvents
  
  releaseLstn = (e) -> btn.className = 'button'
  document.addEventListener(e, releaseLstn) for e in releaseEvents
  releaseLstn()

body = document.getElementsByTagName('body')[0]

rocker(body, (-> cmd 'a-down'), (-> cmd 'a-up'))
tag {className: 'label', parent: body, text: 'Agent'}

rocker(body, (-> cmd 'n-down'), (-> cmd 'n-up'))
tag {className: 'label', parent: body, text: 'Network'}
  
rocker(body, (-> cmd 'g-down'), (-> cmd 'g-up'))
tag {className: 'label', parent: body, text: 'Goal'}

button(body, (-> cmd 'reset'))
tag {className: 'label', parent: body, text: 'Reset'}

      