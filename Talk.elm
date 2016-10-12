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
    px 20

bgColor =
    rgb 255 255 255

codeBgColor =
    rgb 230 230 230

txtColor =
    hex "60B5CC"

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
        , backgroundColor codeBgColor
        ]
    , pre
        [ padding (px 20)
        , fontSize font
        , backgroundColor codeBgColor
        ]
    , img
        [ width (pct 100)
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

            cmd =
                Random.generate MsgRandomInt generator
            ```
            """

        -- TODO: make examples more clear!
        , mdFragments
            [ """
              Problem 1: how do we get an initial seed as soon as we start?
              """

            , """
              ```elm
              Html.App.programWithFlags
              ```
              """

            , """
              ```javascript
              Elm.Main.fullscreen(Date.now())
              ```
              """

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


        , mdFragments
            [ """
              Problem 2: how do I generate complex stuff?
              """

            , """
                ```elm
                type Topping =
                    Onion | Mushroom | Sausage

                type alias Pizza =
                    { cheeseCount : Int
                    , mainTopping : Topping
                    , extraTopping : Maybe Topping
                    }
                ```
              """
            ]

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
                            if hasExtraTopping
                            then Just (int2topping extraToppingIndex)
                            else Nothing

                        randomPizza =
                            Pizza cheeseCount (int2topping mainToppingIndex) extraTopping
                    in
                        (randomPizza, seed3)
                ```
              """

        , mdFragments
            [ " * I made a mistake, did you see it?"
            , " * Lugging around the `seedX` value is a pain!"
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
            ![function f](images/f.png)

            ```elm
            toFloat : Int -> Float

            int2topping : Int -> Topping
            ```
            """

        , mdFragments
            [ """
                ![map f](images/mapf.png)

                ```elm
                (List.map toFloat) : List Int -> List Float

                (Maybe.map toFloat) : Maybe Int -> Maybe Float
                ```
              """
            , """
                ```elm
                (Random.map toFloat) : Generator Int -> Generator Float

                (Random.map int2topping) : Generator Int -> Generator Topping
                ```
              """
            ]

        , mdFragments
            [ "Let's implement it!"
            , """
                ```elm
                type Topping = Onion | Mushroom | Sausage
                ```
              """
            , """
                ```
                int2topping : Int -> Topping
                int2topping index =
                    case index of
                        0 -> Onion
                        1 -> Mushroom
                        _ -> Sausage
                ```
              """
            , """
                ```
                toppingGenerator : Generator Topping
                toppingGenerator =
                    Random.map
                        int2topping
                        (Random.int 0 2)
                ```
              """
            ]

        , md
            """
                What if our function has more than 1 argument?

                ![pizza](images/pizza.png)
            """

        , md
            """
            ![map3 Pizza](images/map3pizza.png)
            """

        , mdFragments
            [ """
                ```elm
                (List.map3 Pizza) :
                    List Int ->
                    List Topping ->
                    List (Maybe Topping) ->
                    List Pizza

                (Maybe.map3 Pizza) :
                    Maybe Int ->
                    Maybe Topping ->
                    Maybe (Maybe Topping) ->
                    Maybe Pizza
                ```
              """
            , """
                ```elm
                (Random.map3 Pizza) :
                    Generator Int ->
                    Generator Topping ->
                    Generator (Maybe Topping) ->
                    Generator Pizza
                ```
              """
            ]

        , mdFragments
            [ "Let's implement it!"
            , """
                ```elm
                pizzaGenerator : Generator Pizza
                pizzaGenerator =
                    Random.map3
                        Pizza
                        (Random.int 0 4)
                        toppingGenerator
                        extraToppingGenerator
                ```
              """
            , """
              ➡ Very clear, very readable
              """
            , """
              ➡ No messing with seeds
              """
            , """
              What about `extraToppingGenerator`?
              """
            ]


        , mdFragments
            [ """
                Unlike `map`, `andThen` can manipulate the container itself:


                ---> Monads apply a function that returns a wrapped value to a wrapped value

                "once you know the result of the genertor A, THEN you use generator B"

                resultOfRandomBool
                        -> Nothing
                        -> Just randomTopping




                ```elm
                extraToppingGenerator : Generator (Maybe Topping)
                extraToppingGenerator =
                    Random.bool `Random.andThen` \\hasTopping ->
                        case hasTopping of
                            False -> Random.constant Nothing
                            True -> Random.map Just toppingGenerator
                ```
              """
            ]




        , mdFragments
            [ """
                This way of composing functions is very general!

                ```elm
                pizzaGenerator : Generator Pizza
                pizzaGenerator =
                    Random.map3
                        Pizza
                        (Random.int 0 4)
                        toppingGenerator
                        extraToppingGenerator
                ```

                ```elm
                pizzaJsonDecoder : Json.Decode.Decoder Pizza
                pizzaJsonDecoder =
                    Json.Decode.object3
                        Pizza
                        ("cheeseCount" := Json.Decode.int)
                        ("mainTopping" := toppingDecoder)
                        (Json.Decode.maybe ("extraTopping" := toppingDecoder))
                ```
              """
            ]

        , mdFragments
            [ """
              @xarvh
              ------

              https://github.com/xarvh/talk-generators
              """
            , """
              Challenge
              ---------

              1. Implement `constant : a -> Generator a`

              1. Implement `map2` and `map3` using only `Random.map` and `Random.andThen`

              1. Implement `combine : List (Generator a) -> Generator (List a)`
              """
            ]
        ]
