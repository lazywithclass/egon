var AWS = require('aws-sdk');
AWS.config.region = 'us-east-1';
var cloudwatchlogs = new AWS.CloudWatchLogs();

module.exports.crossStreams = require('./lib/cross-streams')
  .crossStreams.bind(null, cloudwatchlogs);
