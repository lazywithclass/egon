var async = require('async'),
    _ = require('lodash');

var lib = {};

lib.fetch = function(cloudwatchlogs, tokens, params, cb) {
  var events = [];

  async.forever(function(next) {
    params.nextToken = tokens[params.logStreamName];
    cloudwatchlogs.getLogEvents(params, function(err, res) {
      if (err) console.log(err);
      if (!res) return cb(null, []);

      tokens[params.logStreamName] = res.nextForwardToken;
      cb(null, res.events);

      var proceed = res.events.length !== 0;
      next(proceed ? null : 'finished');
    });
  }, function(err) {

  });
};

var tokens = {};
lib.crossStreams = function(cloudwatchlogs, params, stepCallback) {
  var group = { logGroupName: params.logGroupName };
  cloudwatchlogs.describeLogStreams(group, function(err, data) {
    if (err) return stepCallback(err);
    async.each(
      data.logStreams,
      function(logStream, cb) {
        var clonedParams = _.clone(params);
        clonedParams.logStreamName = logStream.logStreamName;
        lib.fetch(cloudwatchlogs, tokens, clonedParams, stepCallback);
      },
      function(err) {
        // finished
      }
    );
  });
};

module.exports = lib;
