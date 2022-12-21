$(document).ready ->

  $.getJSON "comics.json", (comics) ->

    hash_val = ->
      location.hash.slice(1)

    current = ->
      val = hash_val()
      if val == ""
        0
      else
        parseInt val

    preloading   = false
    queue_barger = null
    errors       = []

    start_preloading_at = (n)->
      errors[n] ||= 0

      return if preloading

      if queue_barger?
        n = queue_barger
        queue_barger = null

      if (url = comics[n])?
        preloading = true

        image = new Image()
        image.src = url
        console.log(image)

        image.onabort = image.onerror = ->
          preloading = false

          errors[n] += 1

          if errors[n] > 3
            # skip this
            start_preloading_at(n+1)
          else
            # retry
            start_preloading_at(n)

        image.onload = ->
          console.log("loaded "+url)
          start_preloading_at(n+1)

    preload_next = ->
      queue_barger = current()+1
      start_preloading_at(current()+1)

    update_comic = ->
      image = comics[current()]
      console.log image
      $("body").css 'background-image': 'url('+image+')'
      preload_next()

    skip = (n)->
      jump(current()+n)

    jump = (n)->
      cookie(n)
      location.hash = n

    $(window).on 'hashchange', ->
      if current() >= comics.length
        jump(comics.length-1)
      else if current() < 0
        jump(0)
      else
        update_comic()

    $("#fwd").on 'click', ->
      skip(1)
    $("#back").on 'click', ->
      skip(-1)

    cookie = (set)->
      if set
        $.cookie("comic", set)
      else
        $.cookie("comic")

    if cookie() and hash_val() == ""
      location.hash = cookie()
    else
      update_comic()

    $('body').keydown (e) ->
      # console.log event: event, key: event.key, code: event.keyCode, ident: event.keyIdentifier

      switch event.key     # event.keyCode
        when 'ArrowRight'  # 39
          skip(1)
        when 'ArrowLeft'   # 37
          skip(-1)
        when 'PageUp'      # 33
          skip(-10)
        when 'PageDown'    # 34
          skip(10)
        when 'End'         # 35
          jump(comics.length-1)
        when 'Home'        # 36
          jump(0)

