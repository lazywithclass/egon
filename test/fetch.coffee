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
    cloudwatchlogs =
      getLogEvents: @sinon.stub().yields(null,
        events: [ message: 'hello', message: 'there' ]
      )
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
    cloudwatchlogs =
      getLogEvents: @sinon.stub().yields(null,
        events: []
        nextForwardToken: 42
      )
    tokenmap = {}
    lib cloudwatchlogs, tokenmap, params, ->
      tokenmap.stream.should.equal 42
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
