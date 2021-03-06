{-
    Copyright 2011-2015 Mario Blazevic

    This file is part of the Streaming Component Combinators (SCC) project.

    The SCC project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
    License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
    version.

    SCC is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with SCC.  If not, see
    <http://www.gnu.org/licenses/>.
-}

-- | This module defines the 'MonoidApplicative' and 'MonoidAlternative' type classes. Their methods are specialized
-- forms of the standard 'Applicative' and 'Alternative' class methods. Instances of these classes should override the
-- default method implementations with more efficient ones.

module Control.Applicative.Monoid (
   MonoidApplicative(..), MonoidAlternative(..)
   )
where

import Control.Applicative (Applicative (pure, (<*>)), Alternative ((<|>), some, many), (<$>))
import Data.Monoid (Monoid, mempty, mappend, mconcat)


class Applicative f => MonoidApplicative f where
   -- | A variant of the Applicative's '<*>' operator specialized for endomorphic functions.
   infixl 4 +<*>
   (+<*>) :: f (a -> a) -> f a -> f a
   (+<*>) = (<*>)

   -- | Lifted and potentially optimized monoid `mappend` operation from the parameter type.
   infixl 5 ><
   (><) :: Monoid a => f a -> f a -> f a
   a >< b = mappend <$> a +<*> b

class (Alternative f, MonoidApplicative f) => MonoidAlternative f where
   -- | Like 'optional', but restricted to 'Monoid' results.
   moptional :: Monoid a => f a -> f a
   moptional x = x <|> pure mempty

   -- | Zero or more argument occurrences like 'many', but concatenated.
   concatMany :: Monoid a => f a -> f a
   concatMany x = many'
      where many' = some' <|> pure mempty
            some' = x >< many'

   -- | One or more argument occurrences like 'some', but concatenated.
   concatSome :: Monoid a => f a -> f a
   concatSome x = some'
      where many' = some' <|> pure mempty
            some' = x >< many'
