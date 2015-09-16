var async = require('async');

var lib = {};

lib.fetch = function(cloudwatchlogs, tokens, params, cb) {
  var events = [];
  _fetch();
  function _fetch() {
    params.nextToken = tokens[params.logStreamName];
    cloudwatchlogs.getLogEvents(params, function(err, res) {
      if (err) console.log(err);
      if (!res) return cb(null, []);

      tokens[params.logStreamName] = res.nextForwardToken;
      if (res.events.length !== 0) {
        events = events.concat(res.events);
        _fetch();
      } else {
        cb(null, events);
      }
    });
  }
};

var tokens = {};
lib.crossStreams = function(cloudwatchlogs, params, cb) {
  var group = { logGroupName: params.logGroupName };
  cloudwatchlogs.describeLogStreams(group, function(err, data) {
    if (err) return cb(err);
    var allEvents = [];
    async.each(
      data.logStreams,
      function(logStream, cb) {
        params.logStreamName = logStream.logStreamName;
        lib.fetch(cloudwatchlogs, tokens, params, function(err, events) {
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
