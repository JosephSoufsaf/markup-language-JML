import AST
import Text.JSON

instance JSON Content where
    showJSON Content str = showJSON str

instance JSKey Tag where
    toJSKey (Tag str) = str
    fromJSKey str = Just (Tag str)