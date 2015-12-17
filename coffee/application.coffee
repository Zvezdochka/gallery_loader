class Application
    constructor: () ->
        @downloadMan=  new DownloadManager()
        @opts = 
            image:
                height: 100
                width: 200
                margin: 20
        $('#downloadButton').on 'click', @download
        $('#pauseButton').on 'click', @pause
        @flag = 'unpaused'

    fetchImages: (filterTags, onDone) ->
        data = 
            page: 1
            imgs_per_page: 15000 
            filter_tags: JSON.stringify filterTags
            mode: 'share_link'
            share_link: @shareLinkCode

        fetching = @apiCall '/images/load/', data
        fetching.done onDone

    download: () =>
        urls = [
            'http://demo.zvezdochka.io/aMG_6668.jpg',
            'http://demo.zvezdochka.io/aMG_6648.jpg',
            'http://demo.zvezdochka.io/DSC_0313.jpg',
            'http://demo.zvezdochka.io/IMG_6671.jpg',
            'http://demo.zvezdochka.io/DSC_1092.jpg',
            'http://demo.zvezdochka.io/aMG_6652.jpg',
            'http://demo.zvezdochka.io/aMG_6719.jpg',
            'http://demo.zvezdochka.io/DSC_0296.jpg',
            'http://demo.zvezdochka.io/DSC_0312.jpg',
            'http://demo.zvezdochka.io/aMG_6675.jpg',
            'http://demo.zvezdochka.io/DSC_0957.jpg',
            'http://demo.zvezdochka.io/aMG_6716.jpg',
            'http://demo.zvezdochka.io/DSC_0970.jpg',
            'http://demo.zvezdochka.io/aSC_1093.jpg',
            'http://demo.zvezdochka.io/DSC_1091.jpg',
            'http://demo.zvezdochka.io/DSC_0956.jpg',
            'http://demo.zvezdochka.io/DSC_0123.jpg',
            'http://demo.zvezdochka.io/IMG_6712.jpg'
        ]
        for num in [0..urls.length-1]
            url = urls[num] + '?' + (+new Date())
            
            imgNode = ($ '<div>')
                    .addClass('item' + num)
                    .html('batch #' + num // 3)
                    .append($('<div>').addClass('percentBox'))
            $('body').append(imgNode)

            loadingIntoLocal = @downloadMan.addTask url
            ((imgNode) -> 
                loadingIntoLocal.done (imgBlobUrl) ->
                    imgNode.css(backgroundImage: 'url('+imgBlobUrl+')')
                    imgNode.html ''

                loadingIntoLocal.progress (percentComplete) ->
                    $('.percentBox', imgNode).html(percentComplete + '%') 
            )(imgNode)

    pause: () =>
        if @flag == 'unpaused'
            @downloadMan.pause()
            $('#pauseButton').html 'Возобновить'
            @flag = 'paused'
        else
            @downloadMan.resume()
            $('#pauseButton').html 'Поставить на паузу'
            @flag = 'unpaused'

    window.Application = Application