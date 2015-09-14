var AWS = require('aws-sdk'),
    async = require('async');

AWS.config.region = 'us-east-1';
var cloudwatchlogs = new AWS.CloudWatchLogs();
var tokens = {};

function unify(logGroupName, cb) {
  cloudwatchlogs.describeLogStreams({ logGroupName: logGroupName }, function(err, data) {
    if (err) return cb(err);

    var allEvents = [];
    async.each(
      data.logStreams,
      function(logStream, cb) {
        run(tokens, logGroupName, logStream.logStreamName, function(err, events) {
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
}

function run(tokens, logGroupName, logStreamName, cb) {
  var params = {
    logGroupName: logGroupName,
    logStreamName: logStreamName,
    nextToken: tokens[logStreamName]
  };

  cloudwatchlogs.getLogEvents(params, function(err, log) {
    if (err) console.log(err);
    if (!log) return cb(null, []);

    tokens[logStreamName] = log.nextForwardToken;
    cb(null, log.events);
  });
}

module.exports = unify;
