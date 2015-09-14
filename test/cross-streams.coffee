should = require 'should'
require 'mocha-sinon'

describe 'crossStreams', ->

  lib = require '../lib/cross-streams'

  beforeEach ->
    stub = @sinon.stub lib, 'fetch'
    stub.onCall(0).yields null, [{
        message: 'hello'
        timestamp: 1
      }, {
        message: 'nice'
        timestamp: 5
      }, {
        message: 'meet'
        timestamp: 10
      }]
    stub.onCall(1).yields null, [{
        message: 'there'
        timestamp: 3
      }, {
        message: 'to'
        timestamp: 7
      }, {
        message: 'you'
        timestamp: 12
      }]

  afterEach ->
    lib.fetch.restore()

  it 'could be required', ->
    should.exist lib

  it 'errors if describeLogStreams errors', (done) ->
    cloudwatchlogs = describeLogStreams: @sinon.stub().yields 'err'
    lib.crossStreams cloudwatchlogs, 'group', (err) ->
      err.should.equal 'err'
      done()

  it 'yields a sorted list of logs', (done) ->
    cloudwatchlogs = describeLogStreams: @sinon.stub().yields null,
      logStreams: [{ logStreamName: 'a' }, { logStreamName: 'b' }]
    lib.crossStreams cloudwatchlogs, 'group', (err, events) ->
      events.should.eql [{
          message: 'hello'
          timestamp: 1
        }, {
          message: 'there'
          timestamp: 3
        }, {
          message: 'nice'
          timestamp: 5
        }, {
          message: 'to'
          timestamp: 7
        }, {
          message: 'meet'
          timestamp: 10
        }, {
          message: 'you'
          timestamp: 12
        }]
      done()
