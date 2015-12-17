class DownloadManager
	constructor: () ->
		@queue = []
		@enRoute = []
		@maxRunningTasks = 3
		@curTaskNum = 0
		@paused = false
		@asyncLoader = new AsyncLoader()

	addTask : (url, downloading) ->
		add = if !downloading then 'push' else 'unshift'
		downloading ?= new $.Deferred() 
		task = {
			xhr: null,
			url: url,
			promise: downloading
			numRetries: 0
		}
		@queue[add] task
		@runTasks()
		downloading

	runTasks: () ->
		while (@queue.length != 0) && (@curTaskNum < @maxRunningTasks) && !@paused
			@runNextTask()
		
	runNextTask: () ->
		task = @queue.shift()
		@enRoute.push task

		@curTaskNum++
		task.numRetries++
		{ downloading, xhr } = @asyncLoader.loadImage task.url
		task.xhr = xhr
		
		downloading.done (imgBlobUrl) =>
			i= @enRoute.indexOf task
			@enRoute.splice i, 1

			task.promise.resolve imgBlobUrl
			@curTaskNum--
			@runTasks()

		downloading.fail =>
			if task.numRetries < 3
				@addTask task.url

		downloading.progress (percentComplete) ->
			task.promise.notify percentComplete

	pause: () ->
		@paused = true
		while @enRoute.length != 0
			task = @enRoute.shift()
			task.xhr.abort()
			@addTask task.url, task.promise
			@curTaskNum--

	resume: () ->
		@paused = false
		@runTasks()

	window.DownloadManager = DownloadManager