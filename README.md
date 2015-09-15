# Egon

> Dr. Egon Spengler: There's something very important I forgot to tell you.<br />
Dr. Peter Venkman: What?<br />
Dr. Egon Spengler: Don't cross the streams.<br />
Dr. Peter Venkman: Why?<br />
Dr. Egon Spengler: It would be bad.<br />

There are some situations when you do want to cross the streams, AWS CloudWatch Logs streams in this case.

## Installation

```bash
$ npm install egon
```

## How to use it

This module combines multiple streams sorting by the `timestamp` field.

```javascript
var logGroupName = 'your-log-group';
egon.crossStreams(logGroupName, function(err, events) {
  // events contains all events in the streams
  // contained in the specified group
});
```

## Running tests

```bash
$ npm test
```

## Release notes

### 0.3.0

Implements [#1](https://github.com/lazywithclass/egon/issues/1), allowing to pass a parameter object that will be forwarded to the `getLogEvents` call.