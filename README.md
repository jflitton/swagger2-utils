# swagger2-utils
Utilities for validating and working with swagger 2.0 documents in Node.js

## Installation
```shell
npm install swagger2-utils
```

## Validate
Validates the supplied swagger document object against the official swagger 2.0 schema.
Returns a boolean indicating validity.

```javascript
var swagger2 = require('swagger2-utils');
var swaggerDoc = require('my-swagger-doc.json');

var valid = swagger2.validate(swaggerDoc);

if valid {
  console.log('valid!');
}
else {
  console.log('failed!');
  throw swagger2.validationError
}
```

## Dereference
Returns a new object where all $ref keys are replaced with the value they reference.

```javascript
var dereferencedDoc = swagger2.dereference(swaggerDoc);
```

