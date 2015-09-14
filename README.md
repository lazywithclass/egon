# Egon

> Dr. Egon Spengler: There's something very important I forgot to tell you.
Dr. Peter Venkman: What?
Dr. Egon Spengler: Don't cross the streams.
Dr. Peter Venkman: Why?
Dr. Egon Spengler: It would be bad.

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