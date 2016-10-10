module Main exposing (..)

import Slides exposing (..)
import Slides.SlideAnimation as SA
import Slides.FragmentAnimation as FA
import Css exposing (..)
import Css.Elements exposing (..)


blur completion =
    "blur(" ++ (toString <| round <| (1 - completion) * 10) ++ "px)"


verticalDeck : SA.Animator
verticalDeck status =
    Css.asPairs <|
        case status of
            SA.Still ->
                [ Css.position Css.absolute
                ]

            SA.Moving direction order completion ->
                case order of
                    SA.LaterSlide ->
                        [ Css.position Css.absolute
                        , Css.property "z-index" "1"
                        , Css.property "filter" (blur completion)
                        , Css.property "-webkit-filter" (blur completion)
                        ]

                    SA.EarlierSlide ->
                        [ Css.position Css.absolute
                        , Css.transform <| Css.translate2 zero (pct (completion * 100))
                        , Css.property "z-index" "2"
                        ]



betterFade : FA.Animator
betterFade completion =
    Css.asPairs
        [ Css.opacity (Css.num completion)
        , Css.property "filter" (blur completion)
        , Css.property "-webkit-filter" (blur completion)
        ]







font =
    (px 20)

bgColor =
    (rgb 255 255 255)

txtColor =
    (hex "60B5CC")

elmBlueOnWhite : List Css.Snippet
elmBlueOnWhite =
    [ body
        [ padding zero
        , margin zero
        , height (pct 100)
        , backgroundColor bgColor
        , color txtColor
        , fontFamilies [ "calibri", "sans-serif" ]
        , fontSize font
        , fontWeight (num 400)
        ]
    , h1
        [ fontWeight (num 400)
        , fontSize (px 38)
        ]
    , section
        [ height (px 700)
        , width (pct 100)
        , backgroundColor bgColor
        , property "background-position" "center"
        , property "background-size" "cover"
        , displayFlex
        , property "justify-content" "center"
        , alignItems center
        ]
    , (.) "slide-content"
        [ margin2 zero (px 90)
        ]
    , code
        [ textAlign left
        , fontSize font
        , padding (px 12)
        ]
    , pre
        [ padding (px 20)
        , fontSize font
        , backgroundColor (rgb 230 230 230)
        ]
    , a
        [ textDecoration none
        , display block
        , color txtColor
        ]
    ]


main =
    Slides.app
        { slidesDefaultOptions
            | style = elmBlueOnWhite
            , slideAnimator = verticalDeck
            , fragmentAnimator = betterFade
--             , animationDuration = 3000
        }
        [ md
            "# Using (random) generators"

        , md
            """
            A generator is something that (duh!) generates values:

            ```elm
            generator =
                Random.int 1 10

            (aRandomIntegerValue, newSeed) =
                Random.step generator oldSeed
            ```
            """
        , md
            """
            How do we use this to generate a complex type?
            """
        , mdFragments
            [ """
                ```elm
                generateSample seed0 =
                    let
                        (seed1, age) =
                            Random.step (Random.int 1 1000) seed0

                        (seed2, latitude) =
                            Random.step (Random.float -90 +90) seed1

                        (seed3, longitude) =
                            Random.step (Random.float -180 +180) seed2

                        randomSample =
                            Sample age latitude longitude
                    in
                        (randomSample, seed3)
                ```
              """
            , "This is ugly! -_-"
            ]
        , md
            """
            We see at once a problem: having to lug around that seed
            is a pain in the ass!
            """
        , mdFragments
            [ "Coming from imperative languages, we are used to compose *values*."
            , "➡ But in a functional language, we compose *functions*."
            ]
        , md
            """
            # A different way of thinking
            """
        , mdFragments
            [ """
                ```elm

                List Int
                Maybe Int
                ```
              """
            , """
                They are "containers" of `Int`

                We can use `map` to manipulate that `Int`
              """
            , """
                ```elm

                (List.map toString) : List Int -> List String
                (Maybe.map toString) : Maybe Int -> Maybe String
                ```
              """
            , "(This is also true for pretty much every type with a `map`)"
            , "http://adit.io/posts/2013-04-17-functors,_applicatives,_and_monads_in_pictures.html"
            ]
        , mdFragments
            [ """
               ```elm

               List Int
               Maybe Int
               Generator Int
               ```
              """
            , """
                ```elm

               (List.map toString) : List Int -> List String
               (Maybe.map toString) : Maybe Int -> Maybe String
               (Random.map toString) : Generator Int -> Generator String
               ```
              """
            ]
        , md
            """
           `map` allows us to work with the value without having it!
            """
        , md
            """
            How can we use this to generate more complex stuff?
            """
        , md
            """
               ```elm

               sampleGenerator : Generator Sample
               sampleGenerator =
                   Random.map3
                       \\age latitude longitude -> Sample age latitude longitude
                       (Random.int 1 1000)
                       (Random.float -90 +90)
                       (Random.float -180 +180)
               ```
            """
        , mdFragments
            [ """
               ```elm

               sampleGenerator : Generator Sample
               sampleGenerator =
                   Random.map3
                       Sample
                       (Random.int 1 1000)
                       (Random.float -90 +90)
                       (Random.float -180 +180)
               ```
              """
            , "➡ No dangerous fumbling around with seeds"
            , "➡ No clutter"
            ]
        , mdFragments
            [ "What if a child generator needs random parameters?"
            , """
               ```elm

               sampleGenerator : Generator Sample
               sampleGenerator =
                   Random.bool `Random.andThen` \\isVeryOld - >
                       Random.map3
                           Sample
                           (Random.int 1 (if isVeryOld then 1000000 else 1000)
                           (Random.float -90 +90)
                           (Random.float -180 +180)
               ```
              """
            ]
        , mdFragments
            [ "We can do pretty much everything by combining `map` and `andThen`"
            , """
                ```elm
                map2 mapper genA genB =
                    genA `andThen` \x07 ->
                        map (mapper a) genB
                ```
              """
            ]
        , md
            """
            Challenge
            ---------

            1. Implement
            ```elm
                constant : a -> Generator a
            ```

            1. Implement
            ```elm
                combine : List (Random.Generator a) -> Random.Generator (List a)
            ```
            """
        , mdFragments
            [ "This is the same pattern used for:"
            , " * Generators (random or otherwise)"
            , " * Encoders, Decoders, Parsers"
            ]
        , md
            """
               See Generators as something more abstract:
               ```elm
                   (aRandomThing, newSeed) =
                       Random.step randomThingGenerator oldSeed
               ```
            """
        , md
            """
               One last problem remaining:

               How do I initialise that seed?
            """
        , mdFragments
            [ "`Html.App.programWithFlags`"
            , "`Elm.Main.fullscreen(Date.now())`"
            , """
                ```elm

                   init : Int -> ( Model, Cmd Msg )
                   init dateNow =
                       let
                           seed = Random.initialSeed dateNow
                       ...
                ```
                """
            ]
        , md
            """

               @xarvh

            """
        ]
