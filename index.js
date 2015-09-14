var AWS = require('aws-sdk'),
    logGroupName = '/aws/lambda/stringify',
    events = require('events'),
    eventEmitter = new events.EventEmitter();

AWS.config.region = 'us-east-1';
var cloudwatchlogs = new AWS.CloudWatchLogs();

var params = { logGroupName: logGroupName };

cloudwatchlogs.describeLogStreams(params, function(err, data) {
  if (err) return console.log(err, err.stack);
  data.logStreams.forEach(function(logStream) {
    run(logGroupName, logStream.logStreamName);
  });
});

function run(logGroupName, logStreamName, nextToken) {
  var params = {
    logGroupName: logGroupName,
    logStreamName: logStreamName,
    nextToken: nextToken
  };

  cloudwatchlogs.getLogEvents(params, function(err, log) {
    if (err) return console.log(err);
    if (!log) return wait(nextToken, run);

    eventEmitter.emit('events', logStreamName, log.events);
    wait(run.bind(null, logGroupName, logStreamName, log.nextForwardToken));
  });
}

function wait(cb) { setTimeout(cb, 2000); }


eventEmitter.on('events', function(a,b) {
  console.log(a,b)
});
