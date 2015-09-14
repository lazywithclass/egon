var AWS = require('aws-sdk');
AWS.config.region = 'us-east-1';
var cloudwatchlogs = new AWS.CloudWatchLogs();

module.exports = require('./lib/unify').unify.bind(null, cloudwatchlogs);
