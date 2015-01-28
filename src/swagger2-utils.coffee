fs = require 'fs'
JaySchema = require 'jayschema'
clone = require 'clone'
traverse = require 'traverse'
Promise = require 'bluebird'
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
exports.validate = (swaggerDoc) ->
  valid = validator.validate swaggerDoc, swaggerSchema
  exports.validationError = if valid then null else validator.getLastErrors()[0]

  valid

###
  Replace internal references with the fragment they reference

  @param {Object} swaggerDoc
###
exports.dereference = (swaggerDoc) ->
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


