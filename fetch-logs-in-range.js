var AWS = require('aws-sdk'),
    cloudwatchlogs = new AWS.CloudWatchLogs(),
    egon = require('./index');

var start = new Date(2015, 8, 25, 6, 0);
var end = new Date(2015, 8, 25, 9, 0);

var params = {
  logGroupName: '/var/log/haproxy.log',
  startTime: start.getTime(),
  endTime: end.getTime(),
  startFromHead: true
};

function fetch(token) {
  if (token) params.nextToken = token;
  egon.crossStreams(params, function(err, logs) {
    if (err) return console.log(err);
    logs.forEach(function(log) {
      console.log(log.message);
    });
  });
}

fetch();
