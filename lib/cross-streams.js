var async = require('async'),
    _ = require('lodash');

var lib = {};

lib.fetch = function(cloudwatchlogs, tokens, params, eventsHandler, done) {
  var previousCallToken = '';
  async.forever(function(next) {
    params.nextToken = tokens[params.logStreamName];
    cloudwatchlogs.getLogEvents(params, function(err, res) {
      if (err || !res) return next(err);

      if (previousCallToken === res.nextForwardToken) return next('finished');
      previousCallToken = res.nextForwardToken;

      tokens[params.logStreamName] = res.nextForwardToken;
      eventsHandler(null, res.events);

      next();
    });
  }, done);
};

var tokens = {};
lib.crossStreams = function(cloudwatchlogs, params, eventsHandler, done) {
  var group = { logGroupName: params.logGroupName };
  cloudwatchlogs.describeLogStreams(group, function(err, data) {
    if (err) return done(err);
    async.each(data.logStreams, function(logStream, next) {
      var clonedParams = _.clone(params);
      clonedParams.logStreamName = logStream.logStreamName;
      lib.fetch(cloudwatchlogs, tokens, clonedParams, eventsHandler, function(err) {
        if (err) return next(err);
        next();
      });
    }, done);
  });
};

// should we stop or should we write to process.stderr in case of err?
function handleError(done, cb) {
  return function() {
    var args = Array.prototype.slice.call(arguments),
        err = args.shift();

    if (err) done(err);
    else cb.apply(null, args);
  };
}

module.exports = lib;
