(ns git-coin-clj.core
  (:require digest
            [clj-http.client :as http]
            [cheshire.core :as json]
            [clojure.core.async :as async]))

;; SPC m e b -- eval buffer
;; SPC m s b -- send and eval buffer in REPL
;; SPC m s B -- send and eval buffer in REPL and switch to REPL in insert mode
;; C-c M-o -- clear REPL buffer output

(def server-url (or (System/getenv "COIN_SERVER") "http://localhost:9292"))
(def miner-name (or (System/getenv "MINER_NAME") "worace"))
(def target-url (str server-url "/target"))
(def send-coin-url (str server-url "/hash"))
(def num-cores (.. Runtime getRuntime availableProcessors))

;; miners will send notifs to this channel when they find a coin
(def coin-notifs (async/chan 10))

(defn fetch-target [] (:body (http/get target-url)))

(def current-target (atom 0))

(defn hash-num [hash] (read-string (str "0x" hash)))

(defn update-target!
  ([] (update-target! (fetch-target)))
  ([target-hash]
   (println (str "set new target! " target-hash))
   (swap! current-target (fn [_] (hash-num target-hash)))))

(defn gen-hash [string] (digest/sha-1 string))

(defn mine [message]
  (let [hash (gen-hash message)]
    (if (< (hash-num hash) @current-target)
      (async/>!! coin-notifs {:hash hash :message message}))
    hash))

(defn check-coin-validity [response]
  ;; When we submit a coin, server sends JSON response like:
  ;; {"success" : true, "new_target" : "updated target"}
  (let [succ ((json/parse-string (response :body)) "success")
        new-target ((json/parse-string (response :body)) "new_target")]
    (if succ
      (update-target! new-target))))

(defn send-coin [message name]
  (http/post
   send-coin-url
   {:form-params {"message" message "owner" name}}))

(defn watch-target [run-switch]
  (async/go
    (while @run-switch
      (async/<! (async/timeout 1000))
      (prn (update-target!))
      )))

(defn mine-loop [identifier run-switch]
  (println "run mine loop")
  (loop [message (str (System/currentTimeMillis) "-" identifier)
         iterations 0]
    (if (= 0 (mod iterations 10000)) (println (str "Miner " identifier " completed " iterations " iterations")))
    (if @run-switch (recur (mine message) (inc iterations))))
  (println (str "miner " identifier " shutting down")))

(defn start-miners [n run-switch]
  ;; Start up N miner threads
  ;; TODO -- what is the most idiomatic / efficient way to do this
  ;; http://stackoverflow.com/questions/1768567/how-does-one-start-a-thread-in-clojure
  ;; what about agents?? also -- how do you shut them down?
  (dotimes [i n]
    (println "in a mine loop")
    ;; (.start (Thread. (partial mine-loop i run-switch)))
    (async/go (mine-loop i run-switch))
    ))

(defn watch-for-coins [run-switch]
  (println "watching for coins")
  (async/go
    (while @run-switch
      (let [coin (async/<! coin-notifs)]
        (println (str "received from chan: "  coin ", target is " (format "%x" (biginteger @current-target ))))
        (check-coin-validity (send-coin (coin :message) "worace"))
        ))))


(def run-switch (atom true))
(defn shutdown! [] (swap! run-switch (fn [_] false)))

(defn run! []
(update-target!)
(watch-for-coins run-switch)
(watch-target run-switch)
(start-miners num-cores run-switch))

(run!)
