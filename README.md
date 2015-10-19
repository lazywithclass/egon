# Egon

> Dr. Egon Spengler: There's something very important I forgot to tell you.<br />
Dr. Peter Venkman: What?<br />
Dr. Egon Spengler: Don't cross the streams.<br />
Dr. Peter Venkman: Why?<br />
Dr. Egon Spengler: It would be bad.<br />
Dr. Peter Venkman: I'm fuzzy on the whole good/bad thing. What do you mean, "bad"?<br />
Dr. Egon Spengler: Try to imagine all life as you know it stopping instantaneously and every molecule in your body exploding at the speed of light.<br />
Dr. Ray Stantz: Total protonic reversal.<br />
Dr. Peter Venkman: Right. That's bad. Okay. All right. Important safety tip. Thanks, Egon.<br />

There are some situations when you do want to cross the streams, AWS CloudWatch Logs streams in this case.

This module combines multiple AWS CloudWatch Logs streams.

## Installation

```bash
$ npm install egon
```

## How to use it

```javascript
var params = {
  logGroupName: 'your-log-group'
};
egon.crossStreams(params, function(err, events) {
  // events contains all events in the streams
  // contained in the specified group
  // in this downloaded batch
}, function(err) {
  // we are done
});
```

Another example with `startTime` and `endTime`.

```javascript
var params = {
  logGroupName: 'your-log-group',
  startTime: start.getTime(),
  endTime: end.getTime(),
  startFromHead: true
};
egon.crossStreams(params, function(err, events) {
  // events contains all events in the streams
  // contained in the specified group
  // in this downloaded batch
}, function(err) {
  // we are done
});
```

## Running tests

```bash
$ npm test
```

## Release notes

### 1.0.0

As noted by the major update I changed `crossStreams` signature, introducing
a handler that is called for every batch of logs, the second function is called
when there are no more logs.

Removed the sorting feature, no more the need to buffer events in memory. Need
to rely on an external sorting tool (`/usr/bin/sort` might help).

### 0.6.1

Added repository field to package.json

### 0.6.0

I've made some stupid mistakes while publishing.

### 0.4.1

Fixes a mutability bad practice that prevented to read the correct events from the streams.

### 0.4.0

Adds support for `startTime` and `endTime`. Logs are buffed in memory.

### 0.3.0

Implements [#1](https://github.com/lazywithclass/egon/issues/1), allowing to pass a parameter object that will be forwarded to the `getLogEvents` call.
