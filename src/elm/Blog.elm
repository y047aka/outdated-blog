module Blog exposing (Post, getPost, getPosts)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Url
import Url.Builder



-- TYPES


type alias Post =
    { date : String
    , path : String
    , title : String
    , tags : List String
    }



-- DECODER


postsDecoder : Decode.Decoder (List Post)
postsDecoder =
    Decode.list postDecoder


postDecoder : Decode.Decoder Post
postDecoder =
    Decode.succeed Post
        |> required "date" Decode.string
        |> required "path" Decode.string
        |> required "title" Decode.string
        |> optional "tags" (Decode.list Decode.string) []



-- API


getPosts : (Result Http.Error (List Post) -> msg) -> Cmd msg
getPosts toMsg =
    Http.get
        { url = "../posts/posts.json"
        , expect = Http.expectJson toMsg postsDecoder
        }


getPost : (Result Http.Error String -> msg) -> String -> String -> Cmd msg
getPost toMsg categoryName fileName =
    Http.get
        { url = "../posts/" ++ categoryName ++ "/" ++ fileName ++ ".md"
        , expect = Http.expectString toMsg
        }
