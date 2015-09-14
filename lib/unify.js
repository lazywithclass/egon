var async = require('async');

var lib = {};

lib.fetch = function(cloudwatchlogs, tokens, group, stream, cb) {
  var params = {
    logGroupName: group,
    logStreamName: stream,
    nextToken: tokens[stream]
  };

  cloudwatchlogs.getLogEvents(params, function(err, res) {
    if (err) console.log(err);
    if (!res) return cb(null, []);

    tokens[stream] = res.nextForwardToken;
    cb(null, res.events);
  });
};

var tokens = {};
lib.unify = function(cloudwatchlogs, group, cb) {
  cloudwatchlogs.describeLogStreams({ logGroupName: group }, function(err, data) {
    if (err) return cb(err);
    var allEvents = [];
    async.each(
      data.logStreams,
      function(logStream, cb) {
        lib.fetch(tokens, group, logStream.logStreamName, function(err, events) {
          allEvents = allEvents.concat(events);
          cb();
        });
      },
      function(err) {
        allEvents.sort(function(a,b) {
          if (a.timestamp < b.timestamp) return -1;
          if (a.timestamp > b.timestamp) return 1;
          return 0;
        });
        cb(null, allEvents);
      }
    );
  });
};

module.exports = lib;
