assert = require 'assert'
clone = require 'clone'
swagger2 = require '../lib/swagger2-utils'
simpleValidDoc = require './testDocuments/simple.json'
docWithReferences = require './testDocuments/hasReferences.json'

docWithReferencesClone = clone docWithReferences

if not String.prototype.startsWith
  Object.defineProperty String.prototype, 'startsWith',
    enumerable: false,
    configurable: false,
    writable: false,
    value: (searchString) ->
      @.lastIndexOf(searchString) is 0

describe 'createOperationsList unit tests', ->
  context 'when the document has a reference', ->
    operations = undefined
    before ->
      operations = swagger2.createOperationsList docWithReferences
      console.log operations

    it 'returns an array of objects', ->
      assert Array.isArray operations
      assert.ok operations.length
      for operation in operations
        assert typeof operation is 'object'

    it 'prepends the basePath to each path', ->
      for operation in operations
        assert operation.path.startsWith docWithReferences.basePath
        console.log operation
