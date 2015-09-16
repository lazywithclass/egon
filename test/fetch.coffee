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

  it 'yields a list of logs', (done) ->
    stub = @sinon.stub()
    stub.onCall(0).yields(null, {
        nextForwardToken: 42
        events: [ message: 'hello', message: 'there' ]
      }).onCall(1).yields(null, {
        nextForwardToken: 43
        events: []
      })
    cloudwatchlogs = getLogEvents: stub
    lib cloudwatchlogs, {}, params, (err, events) ->
      events.should.eql [ message: 'hello', message: 'there' ]
      done()

  it 'yield empty array in case of error', (done) ->
    cloudwatchlogs = getLogEvents: @sinon.stub().yields 'err'
    lib cloudwatchlogs, {}, params, (err, events) ->
      events.should.eql []
      done()

  it 'logs in case of error', (done) ->
    cloudwatchlogs = getLogEvents: @sinon.stub().yields 'err'
    lib cloudwatchlogs, {}, params, (err) ->
      console.log.calledOnce.should.be.true
      console.log.args[0][0].should.equal 'err'
      done()

  it 'stores the token in the mapping', (done) ->
    stub = @sinon.stub()
    stub.onCall(0).yields(null, {
        nextForwardToken: 42
        events: [ message: 'hi' ]
      }).onCall(1).yields(null, {
        nextForwardToken: 43
        events: []
      })
    cloudwatchlogs = getLogEvents: stub
    tokenmap = {}
    lib cloudwatchlogs, tokenmap, params, ->
      stub.args[1][0].nextToken.should.equal 42
      done()

  it 'calls aws with the expected params', (done) ->
    cloudwatchlogs =
      getLogEvents: @sinon.stub().yields null, events: []
    tokenmap = stream: 'hi'
    lib cloudwatchlogs, tokenmap, params, ->
      cloudwatchlogs.getLogEvents.args[0][0].should.eql
        logGroupName: 'group'
        logStreamName: 'stream'
        nextToken: 'hi'
      done()

  it 'buffers in memory in case there are more logs to process', (done) ->
    stub = @sinon.stub()
    stub.onCall(0).yields(null, {
        nextForwardToken: 42
        events: [ message: 'hello' ]
      }).onCall(1).yields(null, {
        nextForwardToken: 43
        events: [ message: 'there' ]
      }).onCall(2).yields(null, {
        nextForwardToken: 44
        events: []
      })
    cloudwatchlogs = getLogEvents: stub
    lib cloudwatchlogs, {}, params, (err, events) ->
      events.should.eql [{ message: 'hello' }, { message: 'there' }]
      done()
