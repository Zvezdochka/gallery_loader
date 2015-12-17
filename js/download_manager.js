// Generated by CoffeeScript 1.8.0
(function() {
  var DownloadManager;

  DownloadManager = (function() {
    function DownloadManager() {
      this.queue = [];
      this.enRoute = [];
      this.maxRunningTasks = 3;
      this.curTaskNum = 0;
      this.paused = false;
      this.asyncLoader = new AsyncLoader();
    }

    DownloadManager.prototype.addTask = function(url, downloading) {
      var add, task;
      add = !downloading ? 'push' : 'unshift';
      if (downloading == null) {
        downloading = new $.Deferred();
      }
      task = {
        xhr: null,
        url: url,
        promise: downloading,
        numRetries: 0
      };
      this.queue[add](task);
      this.runTasks();
      return downloading;
    };

    DownloadManager.prototype.runTasks = function() {
      var _results;
      _results = [];
      while ((this.queue.length !== 0) && (this.curTaskNum < this.maxRunningTasks) && !this.paused) {
        _results.push(this.runNextTask());
      }
      return _results;
    };

    DownloadManager.prototype.runNextTask = function() {
      var downloading, task, xhr, _ref;
      task = this.queue.shift();
      this.enRoute.push(task);
      this.curTaskNum++;
      task.numRetries++;
      _ref = this.asyncLoader.loadImage(task.url), downloading = _ref.downloading, xhr = _ref.xhr;
      task.xhr = xhr;
      downloading.done((function(_this) {
        return function(imgBlobUrl) {
          var i;
          i = _this.enRoute.indexOf(task);
          _this.enRoute.splice(i, 1);
          task.promise.resolve(imgBlobUrl);
          _this.curTaskNum--;
          return _this.runTasks();
        };
      })(this));
      downloading.fail((function(_this) {
        return function() {
          if (task.numRetries < 3) {
            return _this.addTask(task.url);
          }
        };
      })(this));
      return downloading.progress(function(percentComplete) {
        return task.promise.notify(percentComplete);
      });
    };

    DownloadManager.prototype.pause = function() {
      var task, _results;
      this.paused = true;
      _results = [];
      while (this.enRoute.length !== 0) {
        task = this.enRoute.shift();
        task.xhr.abort();
        this.addTask(task.url, task.promise);
        _results.push(this.curTaskNum--);
      }
      return _results;
    };

    DownloadManager.prototype.resume = function() {
      this.paused = false;
      return this.runTasks();
    };

    window.DownloadManager = DownloadManager;

    return DownloadManager;

  })();

}).call(this);
