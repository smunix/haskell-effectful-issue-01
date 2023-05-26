
# Table of Contents

1.  [The Problem](#org5a155b3)



<a id="org5a155b3"></a>

# The Problem

Compiling the following code with ghc961, and ghc927 (using Nix)

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

It fails with fails with `Overlapping instances`

1.  instance (e :> es) => e :> (x : es)
2.  instance [overlapping] e :> e (e : es)

    • Overlapping instances for State (Map a Int)
                                :> (State (Map Int a) : State (Map a Int) : State Int : es)
        arising from a use of ‘runNode’
      Matching instance:
        instance (e :> es) => e :> (x : es)
          -- Defined in ‘Effectful.Internal.Effect’
      Potentially matching instance:
        instance [overlapping] e :> (e : es)
          -- Defined in ‘Effectful.Internal.Effect’
      (The choice depends on the instantiation of ‘a, es’
       To pick the first instance above, use IncoherentInstances
       when compiling the other instance declarations)
    • In the expression: runNode a
      In a \case alternative: Node a -> runNode a

