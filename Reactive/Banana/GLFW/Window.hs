{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}

module Reactive.Banana.GLFW.Window
(
    module Reactive.Banana.GLFW.Types,

    -- * Events
    refresh,
    close,
    focus,
    iconify,

    -- * Position
    position,
    move,

    -- * Size
    size,
    resize,

    -- * Scroll
    scroll
) where

import Control.Monad
import qualified Graphics.UI.GLFW as GLFW

import Reactive.Banana
import Reactive.Banana.Frameworks

import Reactive.Banana.GLFW.Types
import Reactive.Banana.GLFW.Internal.Utils

import Reactive.Banana.GLFW.WindowHandler ( WindowHandler )
import qualified Reactive.Banana.GLFW.WindowHandler as WH


-- | @refresh w@ creates an event that is triggered whenever @window w@ needs
-- to be redrawn, for example if the window has been exposed after having been
-- covered by another window.
refresh :: WindowHandler -> MomentIO (Event ())
refresh = fromAddHandler . WH.refresh


-- | @close w@ creates an event that is triggered when the user attempts to
-- close @window w@, for example by clicking the close widget in the title bar.
--
-- When this is triggered, the close flag has been set and the `GLFW.Window`
-- will close unless the flag is unset.
close :: WindowHandler -> MomentIO (Event ())
close = fromAddHandler . WH.close


-- | @focus w@ creates an event that is triggered when @window w@ gains focus
-- (@True@) or loses focus (@False@).
--
-- When the `GLFW.Window` loses focus, @keyChange w@ and @mouseChange w@
-- will automatically emit release events for any buttons that were held
-- down.
focus :: WindowHandler -> MomentIO (Event Bool)
focus = fromAddHandler . WH.focus


-- | @iconify w@ creates an event that is triggered when @window w@ is iconified
-- (@True@) or restored (@False@).
iconify :: WindowHandler -> MomentIO (Event Bool)
iconify = fromAddHandler . WH.iconify


-- | @move w@ creates an event that emits the position of @window w@ whenever
-- it is moved.
move :: WindowHandler -> MomentIO (Event (Int, Int))
move = fromAddHandler . WH.move


-- | @position w@ creates a behavior that is the position of @window w@.
position :: WindowHandler -> MomentIO (Behavior (Int, Int))
position w = do 
    p <- liftIO (GLFW.getWindowPos (WH.window w)) 
    m <- move w
    stepper p m


-- | @resize w@ creates an event that emits the size of @window w@ whenever it
-- is resized.
resize :: WindowHandler -> MomentIO (Event (Int, Int))
resize = fromAddHandler . WH.resize


-- | @size w@ creates a behavior that is the size of @window w@.
size :: WindowHandler -> MomentIO (Behavior (Int, Int))
size w = do
    s <- liftIO (GLFW.getWindowSize (WH.window w))
    r <- resize w
    stepper s r


-- | @move' w@ creates an event that emits @Just@ the window position whenever
-- @window w@ moves, and emits @Nothing@ when the window is iconified.
move' :: WindowHandler -> MomentIO (Event (Maybe (Int, Int)))
move' w = do
    i <- iconify w
    m <- move w
    spigot (fmap not i) m


-- | @scroll w@ creates an event that emits the scroll offset along 'x' and 'y' axises whenever
-- scrolling device is used, such as a mouse wheel or scrolling area of a touchpad.
scroll :: WindowHandler -> MomentIO (Event (Double, Double))
scroll = fromAddHandler . WH.scroll

{- TODO

-- | @position w@ is @Just@ the window position or @Nothing@ if the window
-- is iconified.
position :: WindowHandler -> Behavior t (Maybe (Double, Double))
position = undefined
-}
