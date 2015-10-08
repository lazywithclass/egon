var async = require('async'), _ = require('lodash');

var lib = {};

lib.fetch = function(aws, tokens, params, eventsHandler, done) {
  var previousCallToken = '';
  async.forever(function(next) {
    params.nextToken = tokens[params.logStreamName];
    aws.getLogEvents(params, handleError(next, function(res) {
      if (previousCallToken === res.nextForwardToken) return next('finished');
      previousCallToken = res.nextForwardToken;
      tokens[params.logStreamName] = res.nextForwardToken;
      eventsHandler(null, res.events);
      next();
    }));
  }, function(err) {
    if (err == 'finished') err = null;
    done(err);
  });
};

var tokens = {};
lib.crossStreams = function(aws, params, eventsHandler, done) {
  var group = { logGroupName: params.logGroupName };
  aws.describeLogStreams(group, handleError(done, function(data) {
    async.each(data.logStreams, function(logStream, next) {
      var clonedParams = _.clone(params);
      clonedParams.logStreamName = logStream.logStreamName;
      lib.fetch(aws, tokens, clonedParams, eventsHandler, handleError(next, next));
    }, done);
  }));
};

function handleError(done, cb) {
  return function() {
    var args = Array.prototype.slice.call(arguments), err = args.shift();
    if (err) done(err);
    else cb.apply(null, args);
  };
}

module.exports = lib;
