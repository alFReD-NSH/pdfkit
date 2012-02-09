###
PDFReference - represents a reference to another object in the PDF object heirarchy
By Devon Govett
###

zlib = require 'zlib'

class PDFReference
    constructor: (@id, @data = {}) ->
        @gen = 0
        @stream = null
        @finalizedStream = null
    object: ->
        @finalize() if not @finalizedStream
        out = ["#{@id} #{@gen} obj"]
        out.push PDFObject.convert(@data)
        
        if @stream || @finalizedStream
            out.push "stream"
            out.push @finalizedStream
            out.push "endstream"
        
        out.push "endobj"
        return out.join '\n'
        
    add: (s) ->
        @stream ?= []
        @stream.push if Buffer.isBuffer(s) then s.toString('binary') else s
        
    finalize: (compress = false, cb) ->
        # cache the finalized stream
        if @stream
            data = @stream.join '\n'
            if compress
                # create a byte array instead of passing a string to the Buffer
                # fixes a weird unicode bug.
                data = new Buffer(data.charCodeAt(i) for i in [0...data.length])
                zlib.deflate data, (err, compressedData) =>
                    if err
                        return cb(err)
                    
                    @finalizedStream = compressedData.toString 'binary'
                    @data.Filter = 'FlateDecode'
                    @data.Length ?= @finalizedStream.length
                    cb null
            else
                @finalizedStream = data
        else
            @finalizedStream = ''
        
    toString: ->
        "#{@id} #{@gen} R"
        
module.exports = PDFReference
PDFObject = require './object'