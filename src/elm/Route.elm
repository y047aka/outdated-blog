module Route exposing (Route(..), parse, parser)

import Url
import Url.Parser as Parser exposing ((</>), (<?>), int, map, s, string, top)


type Route
    = Top
    | Post String String


parse : Url.Url -> Maybe Route
parse url =
    Parser.parse parser url


parser : Parser.Parser (Route -> a) a
parser =
    Parser.oneOf
        [ map Top top
        , map Post (string </> string)
        ]
