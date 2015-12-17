class AsyncLoader
    constructor: () ->
        # @dom = 
        #     progress: $ progressSelector

    loadImage: (url) ->
        # Attention: to be able to load data from another domain/origin with an XHR request, we need the server to return correct Access-Control-Allow-Origin header within response. Fortunately, image storage of Taggy.io does everything just allright :)
        # @link: https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS
        xhr = new XMLHttpRequest()
        xhr.onprogress = (event) =>
            # If browser knows the length of an object being downloaded
            if event.lengthComputable
                percentComplete = Math.round event.loaded / event.total * 100
                loadingImgBlob.notify percentComplete
        
        xhr.onreadystatechange = =>
            # When request is done
            if xhr.readyState == 4
                # If we received successfull response code (304 - image is not modified, browser loads it from cache)
                if (xhr.status >= 200 and xhr.status <= 300) or xhr.status == 304
                    contentType = xhr.getResponseHeader 'Content-Type'
                    contentType = contentType ? 'application/octet-binary'
                    # Create a blob object with response data, so we can obtain url to it
                    blob = new Blob [xhr.response], type: contentType
                    imgBlobUrl = @loadingComplete blob 
                    loadingImgBlob.resolve imgBlobUrl

        # We want response data to be available as ArrayBuffer object containing raw bytes
        xhr.responseType = 'arraybuffer' 
        # Add 'ts' parameter with current timestamp to avoid browser caching
        xhr.open 'GET', url, true
        xhr.send()
        loadingImgBlob = new $.Deferred()
        
        downloading: loadingImgBlob
        xhr: xhr 

    loadingComplete: (blob) ->
        # Get an object url for image
        # @link: https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL
        imgBlobUrl = window.URL.createObjectURL blob
        # console.info 'Object URL:', url

        # @dom.wallpaper.css 'background-image', 'url(' + url + ')'
        # @dom.wallpaper.addClass 'loaded'
        # @dom.progress.addClass 'hidden'
        
        # After object url is used somewhere, we should destroy it, so browser can remove a blob from memory when it's no longer needed
        # @link: https://developer.mozilla.org/en-US/docs/Web/API/URL/revokeObjectURL
        # setTimeout -> window.URL.revokeObjectURL url, 1000
        imgBlobUrl

    window.AsyncLoader = AsyncLoader