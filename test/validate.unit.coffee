assert = require 'assert'
swagger2 = require '../lib/swagger2-utils'
simpleDoc = require './testDocuments/simple.json'
simpleInvalidDoc = require './testDocuments/simpleInvalid.json'
hasReferences = require './testDocuments/hasReferences.json'
hasReferencesInvalid = require './testDocuments/hasReferencesInvalid.json'
swaggerSchema = require '../schema/swagger2Schema.json'

describe 'validate unit tests', ->
  context 'when no schema is specified', ->
    context 'and provided a simple, valid swagger document', ->
      it 'returns true', () ->
        assert swagger2.validate simpleDoc

    context 'and provided a valid document with references', ->
      it 'returns true', () ->
        assert swagger2.validate hasReferences

    context 'and provided a simple, invalid swagger document', ->
      result = undefined
      before ->
        result = swagger2.validate simpleInvalidDoc

      it 'returns false', () ->
        assert result is false

      it 'retains the error in .validationError', ->
        err = swagger2.validationError
        assert err.code is 'OBJECT_ADDITIONAL_PROPERTIES'
        assert.deepEqual err.params, [['getz']]
        assert err.message is 'Additional properties not allowed: ["getz"]'
        assert err.path is '#/paths/~1user'

    context 'and provided an invalid swagger document where the error is in a referenced section', ->
      result = undefined
      before ->
        result = swagger2.validate hasReferencesInvalid

      it 'returns false', () ->
        assert result is false

      it 'retains the error in .validationError', ->
        err = swagger2.validationError

        assert err.code is 'ANY_OF_MISSING'
        assert.deepEqual err.params, []
        assert err.message is "Data does not match any schemas from 'anyOf'"
        assert err.path is '#/definitions/arrayOfStrings/type'

  context 'when a schema is specified', ->
    schema =
      type: "array",
      items:
        type: "string"

    context 'and the instance matches the schema', ->
      result = swagger2.validate(["stuff"], schema)
      console.log swagger2.validationError
      it 'returns true', () ->
        assert result

    context 'and the instance does not match the schema', ->
      result = swagger2.validate({ blah: "stuff" }, schema)
      it 'returns false', () ->
        assert result is false

      it 'retains the error in .validationError', ->
        assert.strictEqual swagger2.validationError.message, "Data does not match any schemas from 'anyOf\'"
