module Reactive.Banana.GLFW.Window
(
    WindowSource(..),
    bindWindowSource,
)
where


import Graphics.UI.GLFW as GLFW
import Reactive.Banana as R
import Reactive.Banana.Frameworks as R

import Reactive.Banana.GLFW.AddHandler


-- | A collection of event sources for a `GLFW.Window`.
data WindowSource f = WindowSource
    { refresh     :: f ()
    , close       :: f ()
    , focus       :: f Bool
    , iconify     :: f Bool
    , position    :: f (Int, Int)
    , size        :: f (Int, Int)
    , key         :: f (Key, Int, KeyState, ModifierKeys)
    , char        :: f Char
    , mouse       :: f (MouseButton, MouseButtonState, ModifierKeys)
    , cursorPos   :: f (Double, Double)
    , cursorEnter :: f Bool
    }


-- | Create an `AddHandler'` for a callback in the shape provided by GLFW-b
handleCallback
    :: ((a -> IO ()) -> cb)
    -> (Maybe cb -> IO ())
    -> IO (AddHandler' a)
handleCallback f cb = do
    (ah, fire) <- newAddHandler
    liftIO $ cb $ Just $ f fire
    return $ AddHandler' ah


hc1 = handleCallback $ \fire _ -> fire ()
hc2 = handleCallback $ \fire _ a -> fire a
hc3 = handleCallback $ \fire _ a b -> fire (a, b)
hc4 = handleCallback $ \fire _ a b c -> fire (a, b, c)
hc5 = handleCallback $ \fire _ a b c d -> fire (a, b, c, d)


bindWindowSource :: GLFW.Window -> IO (WindowSource AddHandler')
bindWindowSource w = WindowSource
    <$> hc1 (GLFW.setWindowRefreshCallback w)
    <*> hc1 (GLFW.setWindowCloseCallback w)
    <*> (fmap (== FocusState'Focused)
        <$> hc2 (GLFW.setWindowFocusCallback w))
    <*> (fmap (== IconifyState'Iconified)
        <$> hc2 (GLFW.setWindowIconifyCallback w))
    <*> hc3 (GLFW.setWindowPosCallback w)
    <*> hc3 (GLFW.setWindowSizeCallback w)
    <*> hc5 (GLFW.setKeyCallback w)
    <*> hc2 (GLFW.setCharCallback w)
    <*> hc4 (GLFW.setMouseButtonCallback w)
    <*> hc3 (GLFW.setCursorPosCallback w)
    <*> (fmap (== CursorState'InWindow)
        <$> hc2 (GLFW.setCursorEnterCallback w))