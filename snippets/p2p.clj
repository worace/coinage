(ns block-chain.core
  (:require [cheshire.core :as json])
  (import [java.net DatagramSocket
           MulticastSocket
           DatagramPacket
           InetAddress
           InetSocketAddress]))

;; backchannel
;; MULTICAST_ADDR = "224.6.8.11"
;; BIND_ADDR = "0.0.0.0"
;; PORT = 6811
;; format
;; client id
;; handle
;; content


 ;; String msg = "Hello";
 ;; InetAddress group = InetAddress.getByName("228.5.6.7");
 ;; MulticastSocket s = new MulticastSocket(6789);
 ;; s.joinGroup(group);
 ;; DatagramPacket hi = new DatagramPacket(msg.getBytes(), msg.length(),
 ;;                             group, 6789);
 ;; s.send(hi);


(def host "224.6.8.11")
(def port 6811)
;; (def socket (MulticastSocket. port))

;; (def group (InetAddress/getByName host))
;; (.joinGroup socket group)

(defn multicast-group [host]
  (InetAddress/getByName host))

(defn multicast-conn [host port]
  (let [socket (MulticastSocket. port)
        group (multicast-group host)]
    (.joinGroup socket group)
    socket))

(defn uid []
  (apply str
         (map int
              (let [b (byte-array 16)]
                (.nextBytes (java.security.SecureRandom.)
                            b)
                b))))

(def client-id (uid))

(def handle "clj-worace")

(defn text->message
  ([text] (json/generate-string {:content text
                                 :client_id client-id
                                 :handle handle})))

(defn send-multicast-msg
  [socket group text]
  (let [message (text->message text)
        dgram (DatagramPacket.
                 (.getBytes message)
                 (count message)
                 group
                 port)]
      (.send socket dgram)))

(defn receive-multicast-message
  [^MulticastSocket socket]
  (let [buffer (byte-array 512)
        packet (DatagramPacket. buffer 512)]
    (.receive socket packet)
    (String. (.getData packet)
             0 (.getLength packet))))

(def running (atom true))
(defn listen [socket]
  (future
    (while @running
      (println "listening for message...")
      (let [m (receive-multicast-message socket)]
        (println (json/parse-string m))))))

(defn open-conn-and-send [message]
  (let [host "224.6.8.11"
        port 6811
        socket (MulticastSocket. port)
        group (InetAddress/getByName host)]
    (.joinGroup socket group)
    (let [dgram (DatagramPacket.
                 (.getBytes message)
                 (count message)
                 group
                 port)]
      (.send socket dgram))
    (.close socket)))

(def message
  "{\"handle\": \"clj-horace\", \"content\": \"hi\", \"client_id\": \"pizza\"}")

(defn send-msg
  "Send a short textual message over a DatagramSocket to the specified
  host and port. If the string is over 512 bytes long, it will be
  truncated."
  [^MulticastSocket socket msg host port]
  (let [payload (.getBytes msg)
        length (min (alength payload) 512)
        address (InetSocketAddress. host port)
        packet (DatagramPacket. payload length address)]
    (.send socket packet)))

(defn receive
  "Block until socket receives UDP message and return the payload
   as a string"
  [^DatagramSocket socket]
  (let [buffer (byte-array 512)
        packet (DatagramPacket. buffer 512)]
    (.receive socket packet)
    (String. (.getData packet) 0 (.getLength packet))))

 ;; // get their responses!
 ;; byte[] buf = new byte[1000];
 ;; DatagramPacket recv = new DatagramPacket(buf, buf.length);
 ;; s.receive(recv);
 ;; ...
 ;; // OK, I'm done talking - leave the group...
 ;; s.leaveGroup(group);
