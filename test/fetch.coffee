should = require 'should'
require 'mocha-sinon'

describe 'fetch', ->

  lib = require('../lib/cross-streams').fetch
  params =
    logGroupName: 'group',
    logStreamName: 'stream'

  beforeEach ->
    log = console.log
    @sinon.stub console, 'log', (text) ->
      return if text == 'err'
      log.apply log, arguments

  afterEach ->
    console.log.restore()

  it 'could be required', ->
    should.exist lib

  it 'calls the event handler everytime there are logs to process', (done) ->
    stub = @sinon.stub()
    stub.onCall(0).yields(null, {
        nextForwardToken: 42
        events: [ message: 'hello' ]
      }).onCall(1).yields(null, {
        nextForwardToken: 43
        events: [ message: 'there' ]
      }).onCall(2).yields(null, {
        nextForwardToken: 43
        events: []
      })
    cloudwatchlogs = getLogEvents: stub
    eventHandler = @sinon.stub()
    lib cloudwatchlogs, {}, params, eventHandler, (err) ->
      eventHandler.callCount.should.equal 2
      eventHandler.args[0][1].should.eql [ message: 'hello' ]
      eventHandler.args[1][1].should.eql [ message: 'there' ]
      done()

  it 'yields error array in case of error', (done) ->
    getLogEvents = @sinon.stub()
    getLogEvents.onCall(0).yields 'err'
    cloudwatchlogs = getLogEvents: getLogEvents
    lib cloudwatchlogs, {}, params, @sinon.stub(), (err, events) ->
      err.should.equal 'err'
      done()

  it 'stores the token in the mapping', (done) ->
    getLogEvents = @sinon.stub()
    getLogEvents.onCall(0).yields(null, {
        nextForwardToken: 42
        events: [ message: 'hi' ]
      }).onCall(1).yields(null, {
        nextForwardToken: 42
        events: []
      })
    cloudwatchlogs = getLogEvents: getLogEvents
    tokenmap = {}
    lib cloudwatchlogs, tokenmap, params, @sinon.stub(), ->
      getLogEvents.args[0][0].nextToken.should.equal 42
      done()

  it 'stops when there are no more events', (done) ->
    stub = @sinon.stub()
    stub.onCall(0).yields(null, {
        nextForwardToken: 42
        events: [ message: 'hello' ]
      }).onCall(1).yields(null, {
        nextForwardToken: 42
        events: []
      })
    cloudwatchlogs = getLogEvents: stub
    lib cloudwatchlogs, {}, params, @sinon.stub(), (err, events) ->
      stub.calledTwice.should.be.true
      done()

  it 'calls aws with the expected params', (done) ->
    cloudwatchlogs =
      getLogEvents: @sinon.stub().yields null, events: []
    tokenmap = stream: 'hi'
    lib cloudwatchlogs, tokenmap, params, @sinon.stub(), ->
      cloudwatchlogs.getLogEvents.args[0][0].should.eql
        logGroupName: 'group'
        logStreamName: 'stream'
        nextToken: undefined
      done()
