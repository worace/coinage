(ns git-coin.target
  (:require [clj-time.core :as time]))

(defonce target (atom 0))

(defn current-target []
  @target)

(defn avg [things]
  (/ (reduce + things) (count things)))

(defn avg-spacing
  "Finds average time spacing in seconds of a series of times"
  [times]
  (->> times
       (partition 2 1)
       (map (partial apply time/interval))
       (map time/in-seconds)
       (avg)))

(defn next-target
  "Adjusts previous target based on time spread of recent blocks.
   last-blocks: seq of previous targets containing :created-at key
   previous-target: numeric previous target
   desired-spacing: desired block spacing in seconds"
  [blocks previous-target desired-spacing]
  (let [spacing (avg-spacing (map :created-at blocks))
        ratio (/ spacing desired-spacing)]
    (* previous-target ratio)))
