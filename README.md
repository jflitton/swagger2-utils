# swagger2-utils
Utilities for validating and working with swagger 2.0 documents in Node.js

## Installation
```shell
npm install swagger2-utils
```

## Validation
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