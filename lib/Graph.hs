{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE UndecidableInstances #-}

module Graph where

import Effectful
import Effectful.Dispatch.Dynamic
import Effectful.State.Dynamic
import Effectful.TH

import Data.Map (Map)
import Data.Map qualified as Map

-- | A Graph  effect on nodes of type a
data Graph a ∷ Effect where
  Node ∷ a → Graph a m ()

makeEffect ''Graph

run
  ∷ ∀ a es r nid a2nid nid2a
   . ( nid ~ Int
     , a2nid ~ Map a nid
     , nid2a ~ Map nid a
     , Ord a
     )
  ⇒ Eff (Graph a : es) r
  → Eff es r
run = reinterpret
  ( evalStateLocal @nid 0
      . evalStateLocal @a2nid Map.empty
      . evalStateLocal @nid2a Map.empty
  )
  \env → \case
    Node a → runNode a
  where
    runNode ∷ ∀ es m. (m ~ Eff es, State a2nid :> es, State nid :> es) ⇒ a → m ()
    runNode a =
      gets @a2nid (Map.lookup a) >>= \case
        Just {} → return ()
        Nothing {} →  modify @nid succ
