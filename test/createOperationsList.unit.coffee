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

    it 'returns an array with one object for each operation', ->
      assert Array.isArray operations
      assert operations.length is 3
      for operation in operations
        assert typeof operation is 'object'

    it 'prepends the basePath to each path', ->
      for operation in operations
        assert operation.path.startsWith docWithReferences.basePath

    it 'merges parameters from the path and operation', ->
      expectedParameters = [
        name: "username",
        type: "string",
        in: "path",
        required: true
      ,
        name: "username",
        type: "string",
        in: "query",
        required: true
      ]
      assert docWithReferences.paths['/user/{username}']?.parameters?
      assert operations[2].parameters?
      assert.deepEqual operations[2].parameters, expectedParameters

    context 'when the operation has a security section', ->
      it 'remains intact', ->
        assert.ok docWithReferences.paths['/user'].get.security
        assert.deepEqual operations[0].security, docWithReferences.paths['/user'].get.security

    context 'when the operation has no security section', ->
      it 'uses the root security section', ->
        assert not docWithReferences.paths['/user'].post.security?
        assert.deepEqual operations[1].security, docWithReferences.security

    context 'when the operation has a produces section', ->
      it 'remains intact', ->
        assert.ok docWithReferences.paths['/user'].get.produces
        assert.deepEqual operations[0].produces, docWithReferences.paths['/user'].get.produces

    context 'when the operation has no produces section', ->
      it 'uses the root security section', ->
        assert not docWithReferences.paths['/user'].post.produces?
        assert.deepEqual operations[1].produces, docWithReferences.produces

    context 'when the operation has a consumes section', ->
      it 'remains intact', ->
        assert.ok docWithReferences.paths['/user'].get.consumes
        assert.deepEqual operations[0].consumes, docWithReferences.paths['/user'].get.consumes

    context 'when the operation has no consumes section', ->
      it 'uses the root security section', ->
        assert not docWithReferences.paths['/user'].post.consumes?
        assert.deepEqual operations[1].consumes, docWithReferences.consumes

    context 'when the operation has a schemes section', ->
      it 'remains intact', ->
        assert.ok docWithReferences.paths['/user'].get.schemes
        assert.deepEqual operations[0].schemes, docWithReferences.paths['/user'].get.schemes

    context 'when the operation has no schemes section', ->
      it 'uses the root security section', ->
        assert not docWithReferences.paths['/user'].post.schemes?
        assert.deepEqual operations[1].schemes, docWithReferences.schemes

    context 'when the path and operation both define the same custom field', ->
      it 'gives precedence to the operation-level value', ->
        assert.ok docWithReferences.paths['/user']['x-custom1']
        assert.ok docWithReferences.paths['/user'].get['x-custom1']
        assert.strictEqual operations[0]['x-custom1'], docWithReferences.paths['/user'].get['x-custom1']

    context 'when the path contains a custom field that the operation lacks', ->
      it 'attaches the custom field to the operation', ->
        assert.ok docWithReferences.paths['/user']['x-custom2']
        assert not docWithReferences.paths['/user'].get['x-custom2']?
        assert.strictEqual operations[0]['x-custom2'], docWithReferences.paths['x-custom2']