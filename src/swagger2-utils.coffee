fs = require 'fs'
clone = require 'clone'
traverse = require 'traverse'
ZSchema = require 'z-schema'
swaggerSchema = require '../schema/swagger2Schema.json'
jsonSchema = require '../schema/json-schema-draft-04.json'

validator = new ZSchema()
validator.setRemoteReference jsonSchema.id, jsonSchema

exports.validationError = null

###
  Validate the provided swagger document using the swagger 2.0 schema

  @param {Object} swaggerDoc
###
validate = exports.validate = (swaggerDoc) ->
  valid = validator.validate swaggerDoc, swaggerSchema
  exports.validationError = if valid then null else validator.getLastErrors()[0]

  valid

###
  Replace internal references with the fragment they reference

  @param {Object} swaggerDoc
###
dereference = exports.dereference = (swaggerDoc) ->
  traverse(swaggerDoc).map (node) ->
    if typeof node is 'object'
      for key, value of node
        if key is '$ref' and value? and typeof value is 'string' and value[0] is '#'
          node = getValueFromPath swaggerDoc, value
    node

###
  Gets the value from the swagger document at the specified path

  @params {Object} swaggerDoc
  @params {String} path  (e.g. #/definitions/user)
###
getValueFromPath = (swaggerDoc, path) ->
  pathParts = path.split '/'

  if pathParts[0] is '#'
    pathParts.shift()

  pathParts.reduce (current, pathPart) ->
    if current? and typeof current is 'object'
      current = current[pathPart]
    else
      current = null

    current
  , swaggerDoc

###
  Turns { someKey: { ... } } into [ { key: someKey, ...} ]
  Disregards key/value pairs where the value isn't an object

  @param {Object} obj
  @param {String} keyName  Optional name to use for the key property in each object
  @returns {Array.<Object>}
###
exports.objectToCollection = (obj, keyName) ->
  keyName = keyName or 'key'
  collection = []

  for key, value of obj
    if value? and typeof value is 'object'
      clonedValue = clone value
      clonedValue[keyName] = key
      collection.push clonedValue

  collection

exports.createOperationsList = (swaggerDoc) ->
  # Validate
  if not validate swaggerDoc
    throw exports.validationError

  # Dereference
  swaggerDoc = dereference swaggerDoc

  # Process
  operations = []

  basePath = swaggerDoc.basePath or ''
  for path, methods of swaggerDoc.paths
    for method, operation of methods
      if method isnt 'parameters'
        newOperation = clone operation
        newOperation.path = basePath + operation.path
        newOperation.method = method
        operations.push newOperation

  operations