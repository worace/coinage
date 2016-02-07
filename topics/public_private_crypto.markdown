# Intro to Public Key Cryptography

In this post, we'll look at the basics of working with Public/Private Key Cryptography from a developer's perspective. We'll talk a bit about the history and advantages of public-key encryption without going too deep into the mathematic ideas that make it all work (perhaps I'll cover this in a future post after doing more research so I can understand it myself...)

## History: Cryptography is Hard

The term Cryptography comes from Greek words for "secret writing," and it seems that people have been trying to write secretly for pretty much as long as they've been trying to write at all. At its core cryptography deals with hiding the contents of a message so it can only be read by those who we choose and over the centuries, cryptographers developed a lot of techniques for doing this. Meanwhile, their adversaries, known as _cryptanalysts_, have been constantly trying to undo everything the cryptographers come up with.

**March Toward Randomness**

There's a lot of interesting stuff to read about in the history of cryptography, but one over-arching trend we can see is a grudging march toward heavy reliance on randomness. The problem, it turns out, is that human language is very _un_-random. Each language has very distinct observable patterns -- in English, for example, we tend to use a lot of vowels, especially "a" and "e" -- and over the years code-breakers were constantly able to use these tendencies to crack into messages. This was especially easy given our tendency to use predictable or formulaic encryption schemes -- rotate letters of the alphabet according to the offsets of a sweetheart's name, a birthdate, etc.

Over time, cryptographers had to accept that the only way to reliably encrypt something is to use true randomness to thoroughly scramble a message. This is best embodied in one of the few encryption schemes still believed to be truly unbreakable -- the [One-Time Pad][otp].

By using random keys, cryptographers were able to escape the inherent predictability of human language. But even this approach comes with some cumbersome restrictions. First, you can't re-use the key. As soon as the randomness of the original key starts to be repeated, patterns emerge, and we're right back where we started (hence _one_-time pad). Note that this includes encrypting messages longer than the key itself, since we would have to re-use key digits. Finally, if we want to reliably use this scheme, we need to distribute and keep track of a *ton* of keys!

![Keys][keys]

And this lands us in a bit of a catch-22. We can't share quality random keys securely if we don't have a good crypto scheme. And we can't have a good crypto scheme of we can't share keys securely...

![Top Secret](http://www.codeproject.com/KB/vista-security/ECDH/spy-vs-spy.gif)
![NSA](https://upload.wikimedia.org/wikipedia/commons/8/84/National_Security_Agency_headquarters,_Fort_Meade,_Maryland.jpg)

* History
* One-Time Pads
* Basics
* Common Algorithms
* Signing vs. Encrypting

[otp]: https://en.wikipedia.org/wiki/One-time_pad
[one-time-pad-example]: http://association-sas.chez-alice.fr/OneTimePadFrench.JPG
[keys]: http://www.gubatron.com/blog/wp-content/uploads/2013/05/Screen-Shot-2013-05-30-at-8.45.12-AM.png
