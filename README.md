# Egon

> Dr. Egon Spengler: There's something very important I forgot to tell you.<br />
Dr. Peter Venkman: What?<br />
Dr. Egon Spengler: Don't cross the streams.<br />
Dr. Peter Venkman: Why?<br />
Dr. Egon Spengler: It would be bad.<br />
Dr. Peter Venkman: I'm fuzzy on the whole good/bad thing. What do you mean, "bad"?<br />
Dr. Egon Spengler: Try to imagine all life as you know it stopping instantaneously and every molecule in your body exploding at the speed of light.<br />
Dr Ray Stantz: Total protonic reversal.<br />
Dr. Peter Venkman: Right. That's bad. Okay. All right. Important safety tip. Thanks, Egon.<br />

There are some situations when you do want to cross the streams, AWS CloudWatch Logs streams in this case.

## Installation

```bash
$ npm install egon
```

## How to use it

This module combines multiple streams sorting by the `timestamp` field.

```javascript
var params = {
  logGroupName: 'your-log-group'
};
egon.crossStreams(params, function(err, events) {
  // events contains all events in the streams
  // contained in the specified group
});
```

If you use `startTime` and `endTime` in `params` beware that logs are stored in memory before being sorted, this is ok for the current usage but that might change if requirements do or if I get lots of requests.<br />
You could increase Node.js limit, for example to 8GB, with `--max-old-space-size=8192`.

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
});
```

## Running tests

```bash
$ npm test
```

## Release notes

### 0.4.1

Fixes a mutability bad practice that prevented to read the correct events from the streams.

### 0.4.0

Adds support for `startTime` and `endTime`. Logs are buffed in memory.

### 0.3.0

Implements [#1](https://github.com/lazywithclass/egon/issues/1), allowing to pass a parameter object that will be forwarded to the `getLogEvents` call.
