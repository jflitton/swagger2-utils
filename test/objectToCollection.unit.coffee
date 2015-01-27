assert = require 'assert'
clone = require 'clone'
swagger2 = require '../lib/swagger2-utils'

describe 'objectToCollection unit tests', ->
  context 'when no key is specified', ->
    input = undefined
    inputClone = undefined
    result = undefined

    before ->
      input =
        a: { some: 'stuff' }
        b: { other: 'thing' }

      inputClone = clone input
      result = swagger2.objectToCollection input
    it "defaults to 'key'", ->
      assert.deepEqual result, [{key: 'a', some: "stuff"},{key: 'b', other:'thing'}]

    it 'does not modify the input object', ->
      assert.deepEqual input, inputClone

  context 'when a key is specified', ->
    it "uses the supplied key", ->
      input =
        a: { some: 'stuff' }
        b: { other: 'thing' }

      result = swagger2.objectToCollection input, 'blerp'
      assert.deepEqual result, [{blerp: 'a', some: "stuff"},{blerp: 'b', other:'thing'}]

  context 'when the input is not an object', ->
    it "returns an empty array", ->
      result = swagger2.objectToCollection 'oh no!'
      assert.deepEqual result, []

  context 'when the input contains a value which is not an object', ->
    it 'does not include the key in the result', ->
      input =
        a: { some: 'stuff' }
        b: 'oh no!'

      result = swagger2.objectToCollection input
      assert.deepEqual result, [{key: 'a', some: 'stuff'}]