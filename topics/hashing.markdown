## Intro to Cryptographic Hashing

"Hashing", or, more specifically, the use of cryptographic hash functions, is essential to the design of Bitcoin. It's important to have at least a basic grasp of this technique before continuing.

### What is Hashing

When we talk about hashing in the context of Bitcoin, we're not talking about tasty breakfast hash:

![Hash](http://www.simplyrecipes.com/photos/corned-beef-hash-b.jpg)

or even about a popular data structure:

```ruby
$ ruby -e "puts({}.class)"
Hash
```

Rather "Hashing" refers to a type of cryptographic function designed to take an arbitrary amount of data and reduce it down to a numeric fingerprint. For example, using the SHA1 hashing function, if we input the string "pizza", we'll get the following fingerprint: "1f6ccd2be75f1cc94a22a773eea8f8aeb5c68217".

There are a few properties of a good hash function that make this ability particularly useful:

1. It's quick to generate a single hash. This makes it easy, for example, to verify that a hash and a piece of data match, since I can just hash the data and check that the hashes match.
2. The fingerprint for a piece of data should be unique to that piece of data (hence the fingerprint analogy. this property is known as __Collision Resistance__)
3. Given a fingerprint, it's extremely difficult to guess what data was used to produce it. Hashing functions are considered **one-way functions**.
4. Even a small change to the input data will result in a wildly different hash being generated. This property is referred to as an **Avalanche Effect**, since a minor input change of even a single bit triggers an "avalanche" of changes to the resulting fingerprint.

pizza:
1f6ccd2be75f1cc94a22a773eea8f8aeb5c68217

list of hash functions

### How does Bitcoin use Hashing to secure the network?

### Other Hashing applications
