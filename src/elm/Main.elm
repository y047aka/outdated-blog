module Main exposing (main)

import Blog exposing (Post)
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Markdown
import Route exposing (Route)
import Url



-- Main


main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Page
    = NotFound
    | ErrorPage Http.Error
    | TopPage (List Post)
    | PostPage String


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    { key = key
    , page = TopPage []
    }
        |> goTo (Route.parse url)



--UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | Loaded (Result Http.Error Page)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            goTo (Route.parse url) model

        Loaded (Ok page) ->
            ( { model | page = page }, Cmd.none )

        Loaded (Err error) ->
            ( { model | page = ErrorPage error }, Cmd.none )


goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Top ->
            ( model
            , Blog.getPosts
                (Result.map TopPage >> Loaded)
            )

        Just (Route.Post categoryName fileName) ->
            ( model
            , Blog.getPost
                (Result.map PostPage >> Loaded)
                categoryName
                fileName
            )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "blog.y047aka.me"
    , body =
        [ siteHeader
        , case model.page of
            NotFound ->
                viewNotFound

            ErrorPage error ->
                viewError error

            TopPage posts ->
                viewTopPage posts

            PostPage post ->
                viewPostPage post
        , siteFooter
        ]
    }


siteHeader : Html Msg
siteHeader =
    header [ class "site-header" ]
        [ nav []
            [ a [ href "/" ] [ text "Top" ]
            ]
        ]


viewNotFound : Html Msg
viewNotFound =
    text "not found"


viewError : Http.Error -> Html Msg
viewError error =
    case error of
        Http.BadBody message ->
            pre [] [ text message ]

        _ ->
            text (Debug.toString error)


viewTopPage : List Post -> Html Msg
viewTopPage posts =
    node "main"
        []
        [ viewPosts "Elm" posts
        , viewPosts "Haskell" posts
        , viewPosts "Tellus" posts
        , viewPosts "Python" posts
        ]


viewPosts : String -> List Post -> Html Msg
viewPosts categoryName posts =
    section []
        [ h1 [] [ text categoryName ]
        , ul
            []
            (posts
                |> List.filter (\post -> List.member categoryName post.tags)
                |> List.map (\post -> li [] [ viewPostLink post ])
            )
        ]


viewPostLink : Post -> Html Msg
viewPostLink post =
    a [ href post.path ]
        [ h1 [] [ text post.title ]
        , text post.date

        --        , ul [] (post.tags |> List.map (\tag -> li [] [ text tag ]))
        ]


viewPostPage : String -> Html Msg
viewPostPage str =
    node "main"
        []
        [ article []
            [ Markdown.toHtmlWith markdownOptions [] str
            ]
        ]


markdownOptions : Markdown.Options
markdownOptions =
    { githubFlavored = Just { tables = True, breaks = False }
    , defaultHighlighting = Nothing
    , sanitize = False
    , smartypants = False
    }


siteFooter : Html Msg
siteFooter =
    footer [ class "site-footer" ]
        [ p [ class "copyright" ] [ text "© 2018-2019 y047aka" ]
        ]
