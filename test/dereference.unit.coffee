assert = require 'assert'
clone = require 'clone'
swagger2 = require '../lib/swagger2-utils'
simpleValidDoc = require './testDocuments/simple.json'
docWithReferences = require './testDocuments/hasReferences.json'
dereferenced = require './testDocuments/dereferenced.json'

docWithReferencesClone = clone docWithReferences

describe 'dereference unit tests', ->
  context 'when the document lacks references', ->
    it 'does nothing', ->
      result = swagger2.deReference simpleValidDoc
      assert.deepEqual result, simpleValidDoc

  context 'when the document has a reference', ->
    result = undefined
    before ->
      result = swagger2.deReference docWithReferences
    it 'dereferences it', ->
      assert.deepEqual result, dereferenced
    it 'returns a copy of the object', ->
      assert result isnt docWithReferences
    it 'does not modify the original object', ->
      assert.deepEqual docWithReferences, docWithReferencesClone