(ns block-chain.net
  (:require [aleph.tcp :as tcp]
            [manifold.stream :as s]
            [clojure.core.async :as async]))


(defn echo-handler [s info]
  (s/connect s s))

(defn server [port]
  (tcp/start-server echo-handler {:port 10001}))

(defn client [host port]
  @(tcp/client {:host host :port port}))

(defn listen [client handler]
  (async/go
    (loop [resp @(s/take! client)]
      (println "got resp: " (apply handler resp))
      (recur @(s/take! client)))
    (println "stopping listen loop")))
