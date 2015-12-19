## ClarkeCoin Reference

This document contains reference examples for the various
data structures and algorithms used in the currency. More
detailed analysis and descriptions are included in the [iterations](https://github.com/worace/coinage/tree/master/iterations)
folder, but if you just need a quick lookup on something, this
is probably the best place.

### Serialization

### Wallets

### Transaction Structure

#### Inputs

##### Unsigned

```json
{
  "source_hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e",
  "source_index": 0,
}
```

##### Signed

```json
{
  "source_hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e",
  "source_index": 0,
  "signature": "psO\/Bs7wt7xbq9VVLnykKp03fKKd4LAzTGnkXjpBhNSgXFt9tGF8f+5QusvRDjjds6NWiet4Bvs2cbfwG2IQfmuAMWwrycrmq8xCpNYnajK+Cyt9ogsU25Q65VYlciXWyrCAIUhtwCJ3Tlwyf1rHbJi6yV4qVHL+7SkxQexlIctlU4r4c0hmofnqcaYCpLfbQ0Kge6NJb7m2NaiWgXhRcJHFVmhQHUUYhxJeZq9PwLoL4nMKWrGKsUC31tRt\/kz+ISROG033oG6LeKGozzGEehL8fMoESS9NEfSQtoGYZ2tvo3xqPSM+mQn852iPMtiBt1UldtiEkX6xdvNWdl3Tfg=="
}
```

#### Outputs

```json
{
  "amount": 5,
  "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
}
```

#### Full Example

{
  "inputs": [
    {
      "source-hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e",
      "source-index": 0,
      "signature": "psO\/Bs7wt7xbq9VVLnykKp03fKKd4LAzTGnkXjpBhNSgXFt9tGF8f+5QusvRDjjds6NWiet4Bvs2cbfwG2IQfmuAMWwrycrmq8xCpNYnajK+Cyt9ogsU25Q65VYlciXWyrCAIUhtwCJ3Tlwyf1rHbJi6yV4qVHL+7SkxQexlIctlU4r4c0hmofnqcaYCpLfbQ0Kge6NJb7m2NaiWgXhRcJHFVmhQHUUYhxJeZq9PwLoL4nMKWrGKsUC31tRt\/kz+ISROG033oG6LeKGozzGEehL8fMoESS9NEfSQtoGYZ2tvo3xqPSM+mQn852iPMtiBt1UldtiEkX6xdvNWdl3Tfg=="
    }
  ],
  "outputs": [
    {
      "amount": 5,
      "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxpaKTGz1LlgVihe0dGlE\nPsn\/cJk+Zo7uePr8hhjCAj+R0cxjE4Q8xKmVAA3YAxenoo6DShn8CSvR8AvNDgMm\nAdHvKjnZXsyPBBD+BNw5vIrEgQiuuBl7e0P8BfctGq2HHlBJ5i+1zitbmFe\/Mnyr\nVRimxM7q7YGGOtqQ5ZEZRL1NcvS2sR+YxTL5YbCBXUW3FzLUjkmtSEH1bwWADCWj\nhz6IXWqYU0F5pRECVI+ybkdmirTbpZtQPyrND+iclsjnUUSONDLYm27dQnDvtiFc\nIn3PZ3Qxlk9JZ6F77+7OSEJMH3sB6\/JcPZ0xd426U84SyYXLhggrBJMXCwUnzLN6\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
    }
  ],
  timestamp: 1450310016721,
  "hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e"
}

#### Coinbase

Coinbase transactions represent mining rewards. Only one is allowed
per block and they must appear as the **first** transaction in that block.
Coinbase txn has no inputs.

```json
{
    "inputs": [],
    "outputs": [
        {
            "amount": 25,
            "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"
        }
    ],
    "timestamp": 1450565806588,
    "hash": "789509258c985783a0c6f99a29725a797bcdcaf3a94c17b077a228fd2a572fa9"
}
```

### Block Structure

#### Unmined

#### Mined

### Working with Hexadecimal

When working with numbers represented as hexadecimal strings,
use "lowercased" hex strings using the digits 0-9 and the
lowercase letters "a" - "f".

That is, `7fa18e`, not `7FA18E`.

### JSON Conventions

### Timestamps
