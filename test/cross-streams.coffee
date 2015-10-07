should = require 'should'
require 'mocha-sinon'

describe 'crossStreams', ->

  lib = require '../lib/cross-streams'
  params = logGroupName: 'group'

  beforeEach ->
    stub = @sinon.stub lib, 'fetch'
    stub.onCall(0).callsArgWithAsync 4, null, [{
        message: 'hello'
        timestamp: 1
      }, {
        message: 'nice'
        timestamp: 5
      }, {
        message: 'meet'
        timestamp: 10
      }]
    stub.onCall(1).callsArgWithAsync 4, null, [{
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
    lib.crossStreams cloudwatchlogs, params, @sinon.stub(), (err) ->
      err.should.equal 'err'
      done()

  it 'yields a list of logs', (done) ->
    cloudwatchlogs = describeLogStreams: @sinon.stub().yields null,
      logStreams: [{ logStreamName: 'a' }, { logStreamName: 'b' }]

    eventsHandler = @sinon.stub()
    lib.crossStreams cloudwatchlogs, params, eventsHandler, (err) ->
      eventsHandler.args[0][0].should.eql []
      done()

  it 'errors if lib.fetch errors', (done) ->
    lib.fetch.restore()
    @sinon.stub(lib, 'fetch').callsArgWithAsync 4, 'err'
    cloudwatchlogs = describeLogStreams: @sinon.stub().yields null,
      logStreams: [{ logStreamName: 'a' }]

    lib.crossStreams cloudwatchlogs, params, @sinon.stub(), (err, events) ->
      err.should.equal 'err'
      done()
