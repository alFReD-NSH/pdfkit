PDFImage    = require '../image'
async       = require 'async'

module.exports =
    initImages: ->
        @_imageRegistry = {}
        @_imageCount = 0
        @ids = 1
        
    image: (contents, options = {}, cb) ->
        if typeof options is 'function'
            cb = options
            options = {}
            
        id = options.id ? @ids++
        console.log id
        x = options.x ? @x
        y = options.y ? @y
        
        continueF = (err, [image, obj, label]) =>
            if err
                return cb err
                
            w = options.width or image.width
            h = options.height or image.height
            
            if options.width and not options.height
                wp = w / image.width
                w = image.width * wp
                h = image.height * wp
    
            else if options.height and not options.width
                hp = h / image.height
                w = image.width * hp
                h = image.height * hp
    
            else if options.scale
                w = image.width * options.scale
                h = image.height * options.scale
    
            else if options.fit
                [bw, bh] = options.fit
                bp = bw / bh
                ip = image.width / image.height
                if ip > bp
                    w = bw
                    h = bw / ip
                else
                    h = bh
                    w = bh * ip
            
            # Set the current y position to below the image if it is in the document flow            
            @y += h if @y is y
    
            y = @page.height - y - h
            @page.xobjects[label] ?= obj
    
            @save()
            @addContent "#{w} 0 0 #{h} #{x} #{y} cm"
            @addContent "/#{label} Do"
            @restore()

            cb null
            
        if @_imageRegistry[id]
            continueF @_imageRegistry[id]
        else
            image = PDFImage.open contents
            image.object this, (err, obj) =>
                continueF err, @_imageRegistry[id] = [image, obj, "I" + (++@_imageCount)]
                
        
