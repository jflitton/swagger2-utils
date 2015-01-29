fs = require 'fs'
clone = require 'clone'
traverse = require 'traverse'
ZSchema = require 'z-schema'
swaggerSchema = require '../schema/swagger2Schema.json'
jsonSchema = require '../schema/json-schema-draft-04.json'

validator = new ZSchema()
validator.setRemoteReference jsonSchema.id, jsonSchema
exports.validationError = null

customFieldPattern = /^x-/

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
    if current?[pathPart]?
      current = current[pathPart]
    else
      throw new Error "Bad reference to path #{path}"

    current
  , swaggerDoc

###
  Turns { someKey: { ... } } into [ { key: someKey, ...} ]
  Disregards key/value pairs where the value isn't an object

  @param {Object} obj
  @param {String} keyName  Optional name to use for the key property in each object
  @returns {Array.<Object>}
###
objectToCollection = exports.objectToCollection = (obj, keyName) ->
  if keyName is undefined
    keyName = 'key'

  collection = []

  for key, value of obj
    if value? and typeof value is 'object'
      clonedValue = clone value
      if keyName isnt null
        clonedValue[keyName] = key
      collection.push clonedValue

  collection

###
  Adds an array of swagger parameters to the provided object, checking for duplicates.
  Duplicates have the same name and location.

  @param {Array.<Object>} paramArray
  @param {Object} paramObject
  @returns undefined
###
addParameters = (paramArray, paramObject) ->
  for param in paramArray
    paramObject[param.name+param.in] = param

###
  Validates and dereferences the swagger document then creates a list of concrete operations
  after applying precedence rules.

  @param {Object} swaggerDoc
  @returns {Array.<Object>}
###
exports.createOperationsList = (swaggerDoc) ->
  # Validate
  if not validate swaggerDoc
    throw exports.validationError

  # Dereference
  swaggerDoc = dereference swaggerDoc

  # Create the list
  results = []

  basePath = swaggerDoc.basePath or ''
  for path, methods of swaggerDoc.paths
    pathCustomFieldNames = []
    operations = {}
    for key, value of methods
      if customFieldPattern.test key
        # This is a custom field
        pathCustomFieldNames.push key

      else if key isnt 'parameters'
        # All other keys are operations
        operations[key] = value

    for method, operation of operations
      newOperation = clone operation
      newOperation.path = basePath + path
      newOperation.method = method
      newOperation.security = operation.security or swaggerDoc.security or []
      newOperation.produces = operation.produces or swaggerDoc.produces or []
      newOperation.consumes = operation.consumes or swaggerDoc.produces or []
      newOperation.schemes = operation.schemes or swaggerDoc.schemes or []

      # Attach any custom fields defined that the path level that aren't defined at the operation level
      for customFieldName in pathCustomFieldNames
        if not newOperation[customFieldName]?
          newOperation[customFieldName] = path[customFieldName]

      # Combine the operation and path-level parameters
      parameters = {}
      addParameters methods.parameters or [], parameters
      addParameters operation.parameters or [], parameters
      newOperation.parameters = objectToCollection parameters, null

      results.push newOperation

  results