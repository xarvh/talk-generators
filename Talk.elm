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



        , md
            """
                ```elm
                type Topping = Onion | Mushroom | Sausage

                type alias Pizza =
                    { cheeseCount : Int
                    , mainTopping : Topping
                    , extraTopping : Maybe Topping
                    }
                ```
            """

        , md
            """
                ```elm
                generatePizza seed0 =
                    let
                        (seed1, cheeseCount) =
                            Random.step (Random.int 0 4) seed0

                        (seed2, mainToppingIndex) =
                            Random.step (Random.int 0 2) seed1

                        (seed3, extraToppingIndex) =
                            Random.step (Random.int 0 2) seed2

                        (seed4, hasExtraTopping) =
                            Random.step Random.bool seed3

                        extraTopping =
                            if hasExtraTopping then Just (int2topping extraToppingIndex) else Nothing

                        randomPizza =
                            Pizza cheeseCount (int2topping mainToppingIndex) extraTopping
                    in
                        (randomPizza, seed3)
                ```
              """

        , mdFragments
            [ " * I made a mistake, did you see it?"
            , " * lugging around the `seedX` value is a pain!"
            , " * Clutter: difficult to understand the function"
            , " * I generate `extraToppingIndex` even when I don't use it"
            ]

        , mdFragments
            [ "Coming from imperative languages, we are used to compose *values*."
            , "➡ But in a functional language, we compose *functions*."
            ]

        , md
            """
            # A different way of thinking
            """

        , md
            """
            [img   f : Star -> Triangle]

            example: `toFloat : Int -> Float`
            """

        , mdFragments
            [ """
                [img   (map f) : container Star -> container Triangle]

                ```elm
                (List.map toFloat) : List Int -> List Float
                (Maybe.map toFloat) : Maybe Int -> Maybe Float
                ```
              """
            , """
                ```
                (Random.map toFloat) : Generator Int -> Generator Float
                ```
              """
            ]

        , mdFragments
            [ """
                What if our function has more than 1 argument?

                [img g : Star -> Circle -> Square -> Triangle]

                ```elm
                (List.map3 Pizza) : List Int -> List Topping -> List (Maybe Topping) -> List Pizza
                (Maybe.map3 Pizza) : Maybe Int -> Maybe Topping -> Maybe (Maybe Topping) -> Maybe Pizza
                ```
              """
            , """
                ```
                (Random.map3 Pizza) : Generator Int -> Generator Topping -> Generator (Maybe Topping) -> Generator Pizza
                ```
              """
            ]

        , md
            """
                ```
                pizzaGenerator : Random.Generator Pizza
                pizzaGenerator =
                    Random.map3
                        \\cheeseCount mainTopping extraTopping -> Pizza cheeseCount mainTopping extraTopping
                        (Random.int 0 4)
                        toppingGenerator
                        extraToppingGenerator
                ```
            """

            -- TODO: mainTopping generator
            -- TODO: extraToppingGenerator


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



        -- TODO: move at beginning
        , md
            """
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
