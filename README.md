# swagger2-utils
Utilities for validating and working with swagger 2.0 documents in Node.js

## Installation
```shell
npm install swagger2-utils
```

## Validate
Validates the supplied swagger document object against the official swagger 2.0 schema.
```javascript
var swagger2 = require('swagger2-utils');
var swaggerDoc = require('my-swagger-doc.json');

try {
  swagger2.validate(swaggerDoc);
  console.log('valid!');
} catch (err) {
  console.log('failed!');
}
```

## Dereference
Returns a new object where all $ref keys are replaced with the value they reference.

```javascript
var dereferencedDoc = swagger2.dereference(swaggerDoc);
```

