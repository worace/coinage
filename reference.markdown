## ClarkeCoin Reference

This document contains reference examples for the various
data structures and algorithms used in the currency. More
detailed analysis and descriptions are included in the [iterations](https://github.com/worace/coinage/tree/master/iterations)
folder, but if you just need a quick lookup on something, this
is probably the best place.

### Wallets

A "wallet" is just an RSA public/private keypair. The public key
serves as your address for receiving funds from other users, and
the private key serves as your means of signing these funds to unlock
them for spending.

* Algorithm: RSA
* Key Size: 2048
* Serialization: Use PEM encoding format

### Transaction Structure

#### Inputs

Transaction inputs spend funds by identifying a transaction output
from a previous transaction.

The previous output is identified by a transaction hash (identifying which transaction)
and an index (identifying which output within the list of outputs in that txn.)

Additionally, an input contains an RSA signature from the appropriate
private key.

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

```json
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
  "timestamp": 1450310016721,
  "hash": "9ed1515819dec61fd361d5fdabb57f41ecce1a5fe1fe263b98c0d6943b9b232e"
}
```


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

(Nonce value of `0` and block hash greater than target)

```json
{
    "header": {
        "parent_hash": "0000000000000000000000000000000000000000000000000000000000000000",
        "transactions_hash": "203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654",
        "target": "0000100000000000000000000000000000000000000000000000000000000000",
        "timestamp": 1450564013,
        "nonce": 0,
        "hash": "65cc0cff6f61c81443152ec64fa7ac3d26733173eea6235e0ef4f986e31f9836"
    },
    "transactions": [
        {
            "inputs": [],
            "outputs": [
                {
                    "amount": 25,
                    "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"
                }
            ],
            "timestamp": 1450564013887,
            "hash": "933de73b476eb420aadc3c0e5959c6b0e3d1a58c4f997bd60bcbdbb5a0beeb90"
        }
    ]
}
```

#### Mined

```json
{
    "header": {
        "parent_hash": "0000000000000000000000000000000000000000000000000000000000000000",
        "transactions_hash": "203a0e37fa56a530f678d6331baf83a7b72d5d67c189aeb3ca17ed8a2a5bc654",
        "target": "0000100000000000000000000000000000000000000000000000000000000000",
        "timestamp": 1450564013,
        "nonce": 1354641,
        "hash": "000002b889bb79228ff41f86a65e2e0e143955cf746c2a33ed223d2701cd9c72"
    },
    "transactions": [
        {
            "inputs": [],
            "outputs": [
                {
                    "amount": 25,
                    "address": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuFl76216Veu5\/H2MM4lO\nNFOuZLGcwxeUQzdmW2g+da5mmjyV3RiuYueDJFlAgx2iDASQM+rK1qKp7lj352DU\n3gABqJ5Tk1mRvGHTGz+aP4sj8CKUnjJIQVmmleiRZ47wRDsnrg9N0XyfW+aiPKxl\njvr1pkKJmryO+u2d69Tc69bNsqpGzFLTdO3w1k\/jxa0pUAQNqf11MJSrzF7u\/Z+8\nmaqFZlzZ5o1LgqTLMpeFg0pcMIKuZb9yQ1IKqOjLsvTvYYyBbNU31FD8qVY\/R64z\nbrIYbfWXNiUrYOXyIq7rqegLf3fx+aJGgwUOGYr2MJjY+ZR5Z+cIKJiAgNnpkBWR\nhwIDAQAB\n-----END PUBLIC KEY-----\n"
                }
            ],
            "timestamp": 1450564013887,
            "hash": "933de73b476eb420aadc3c0e5959c6b0e3d1a58c4f997bd60bcbdbb5a0beeb90"
        }
    ]
}
```

### Working with Hexadecimal

When working with numbers represented as hexadecimal strings,
use "lowercased" hex strings using the digits 0-9 and the
lowercase letters "a" - "f".

That is, `7fa18e`, not `7FA18E`.

### JSON Conventions

When serializing structures as JSON, use `snake_case` key names.

That is, `{"pizza_pie": "lol"}`, not `{"pizzaPie": "lol"}`

### Timestamps

Use Unix epoch timestamps. Some instances will call for seconds
and some for milliseconds.
