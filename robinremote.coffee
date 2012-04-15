
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

rocker = (parent, downFunc, upFunc) ->
  outer = tag {className: 'rocker', parent}
  down = tag {className: 'down', parent: outer}
  tag {className: 'minus', parent: down}
  tag {className: 'divider', parent: down}
  up = tag {className: 'up', parent: outer}
  tag {className: 'plus-h', parent: up}
  tag {className: 'plus-v', parent: up}
  tag {className: 'shadow-hider', parent: up}   
  down.addEventListener 'mousedown', ->
    down.stdClass = down.className
    down.className += ' highlighted'
    downFunc()  
  down.addEventListener 'mouseup', ->
    down.className = down.stdClass
  up.addEventListener 'mousedown', ->
    up.stdClass = up.className
    up.className += ' highlighted'
    upFunc()  
  up.addEventListener 'mouseup', ->
    up.className = up.stdClass

button = (parent, func) ->
  btn = tag {className: 'button', parent}  
  btn.addEventListener 'mousedown', ->
    btn.stdClass = btn.className
    btn.className += ' highlighted'
    func()  
  btn.addEventListener 'mouseup', ->
    btn.className = btn.stdClass

body = document.getElementsByTagName('body')[0]

rocker(body, (-> cmd 'a-down'), (-> cmd 'a-up'))
tag {className: 'label', parent: body, text: 'Agents'}

rocker(body, (-> cmd 'n-down'), (-> cmd 'n-up'))
tag {className: 'label', parent: body, text: 'Network'}
  
rocker(body, (-> cmd 'o-down'), (-> cmd 'o-up'))
tag {className: 'label', parent: body, text: 'Nodes'}

button(body, (-> cmd 'reset'))
tag {className: 'label', parent: body, text: 'Reset'}

      
      