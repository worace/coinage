(ns block-chain.wallet
  (:require [clojure.java.io :as io])
  (:import
    (org.bouncycastle.openpgp
     PGPUtil)
    (org.bouncycastle.openssl
     PEMParser)
    (java.security
     KeyFactory)
    (java.security.spec
     PKCS8EncodedKeySpec)))

;; Thanks to http://nakkaya.com/2012/10/28/public-key-cryptography/
;; for most of these snippets

(java.security.Security/addProvider
 (org.bouncycastle.jce.provider.BouncyCastleProvider.))

(defn decode64 [str]
  (.decode (java.util.Base64/getDecoder) str))

(defn encode64 [bytes]
  (.encodeToString (java.util.Base64/getEncoder) bytes))

(defn keydata [reader]
 (->> reader
      (PEMParser.)
      (.readObject)))

(defn read-pem-private-key [filepath]
  (let [kd (keydata (io/reader filepath))]
    (.getKeyPair (org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter.) kd)))

(defn read-pem-public-key [filepath]
  (let [kd (keydata (io/reader filepath))
        kf (KeyFactory/getInstance "RSA")
        spec (java.security.spec.X509EncodedKeySpec. (.getEncoded kd))]
    (.generatePublic kf spec)))

(defn read-pem-public-key-from-string [string]
  (let [kd (keydata (io/reader (.getBytes string)))
        kf (KeyFactory/getInstance "RSA")
        spec (java.security.spec.X509EncodedKeySpec. (.getEncoded kd))]
    (.generatePublic kf spec)))

(defn kp-generator []
  (doto (java.security.KeyPairGenerator/getInstance "RSA" "BC")
    (.initialize 2048)))

(defn generate-keypair []
  (.generateKeyPair (kp-generator)))

(defn encrypt [bytes public-key]
  (let [cipher (doto (javax.crypto.Cipher/getInstance "RSA/ECB/PKCS1Padding" "BC")
                 (.init javax.crypto.Cipher/ENCRYPT_MODE public-key))]
    (.doFinal cipher bytes)))


(defn decrypt [bytes private-key]
  (let [cipher (doto (javax.crypto.Cipher/getInstance "RSA/ECB/PKCS1Padding" "BC")
                 (.init javax.crypto.Cipher/DECRYPT_MODE private-key))]
    (.doFinal cipher bytes)))

(defn sign [data private-key]
  (let [sig (doto (java.security.Signature/getInstance "SHA1withRSA" "BC")
              (.initSign private-key (java.security.SecureRandom.))
              (.update data))]
    (.sign sig)))

(defn verify [signature data public-key]
  (let [sig (doto (java.security.Signature/getInstance "SHA1withRSA" "BC")
              (.initVerify public-key)
              (.update data))]
    (.verify sig signature)))

(def keypair (generate-keypair))
(def private-key (read-pem-private-key "/Users/worace/Desktop/keys/private_key.pem"))
(def public-key (read-pem-public-key "/Users/worace/Desktop/keys/public_key.pem"))

(let [encrypted (encrypt (.getBytes "Pizza") public-key)]
  (println "decryted: " (map char (decrypt encrypted (.getPrivate private-key)))))

(def message "jFd5MRjGs3S19XIblzdkVkEwUc7A7WRPdWtj6JPXuqU6k/ue1sLRLRhc0inu\nNUglbx3TJTcq6i2FvIA1wb7LnMfw9MiFVs/wbxhtQFmx9VYKHLQq7pqKiYkZ\n6Mqtr1SiUT5e6OFc+6WEIj6GzaF6LRU9osGmUQs40iPQr5016XafRCDeIval\nNo8na5C2WZu4m4ZYadnOwDkAbuk4Vhd7xxR+F433Qitncux8oKHhVOpR9yYV\n7JzNVPzC5o+fX8PNns39Pcb91m3Z243GOl8xlfBFPYa0Wytd9DJB13MYAiWQ\n6gAGUa3kYJJIqMQU3Yyz0DCvRtoJiFXacrJoAvQ5zg==")

(def sample-pub-key-string
  "-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDGU3lYomZqoluRGcM76VPYALvY
Asel+CUivvKK6A6NUf9bWrqU3GsNi2biHzn7JrIaTxeEu0vw7MFi1dd5nxzuI/ow
f0vyp+SSDGQ/EuSgrFwIZowHD/9QFMMiFZbqCxPzvxKYljPE5BsCLI7sWwotseQ1
iUxRHiIhvSo/3md7XwIDAQAB
-----END PUBLIC KEY-----
")

(let [pubkey (read-pem-public-key-from-string sample-pub-key-string)
      encrypted (encrypt (.getBytes "Hi Josh!") pubkey)]
  (println "Encrypted 'Hi Josh!':")
  (println (encode64 encrypted)))
